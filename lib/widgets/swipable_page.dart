import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A [PageRoute] that enables iOS-like full back-swipe gesture from the left edge.
///
/// - Starts a pop gesture when the user swipes from the left edge within
///   [edgeStartWidthPx], regardless of the presence of horizontal scrollables.
/// - If the drag starts outside the left edge, the pop gesture is allowed only
///   when the upper-most horizontal scrollable (if any) is scrolled to its
///   left boundary. This keeps natural interaction with widgets like
///   [PageView] or horizontally scrolling lists.
/// - The route slides in from the right on push and slides back to the right
///   on pop, using [pushCurve] and [popCurve] respectively.
///
/// Example:
/// ```dart
/// Navigator.of(context).push(
///   BackSwipePageRoute(builder: (_) => const DetailPage()),
/// );
/// ```
class BackSwipePageRoute<T> extends PageRouteBuilder<T> {
  /// Creates a back-swipe enabled page route.
  BackSwipePageRoute({
    required WidgetBuilder builder,
    super.settings,
    super.maintainState,
    super.transitionDuration = const Duration(milliseconds: 150),
    super.reverseTransitionDuration = const Duration(milliseconds: 150),
    this.edgeStartWidthPx = 24.0,
    this.pushCurve = Curves.easeOutCubic,
    this.popCurve = Curves.easeIn,
  }) : super(
    opaque: false,
    barrierColor: Colors.transparent,
    barrierDismissible: false,
    pageBuilder: (context, a1, a2) => builder(context),
    transitionsBuilder: (context, a1, a2, child) {
      final isReverse = a1.status == AnimationStatus.reverse;
      final curve = isReverse ? popCurve : pushCurve;

      final slide = a1.drive(
        Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: curve)),
      );

      return SlideTransition(
        position: slide,
        child: _BackSwipeInteractor(
          edgeStartWidthPx: edgeStartWidthPx,
          child: child,
        ),
      );
    },
  );

  /// Logical pixels from the left edge within which back-swipe always starts
  /// (mimicking iOS' edge-swipe behavior).
  final double edgeStartWidthPx;

  /// Curve used for the forward (push) transition.
  final Curve pushCurve;

  /// Curve used for the reverse (pop) transition.
  final Curve popCurve;
}


class SwipeablePage extends StatefulWidget {
  const SwipeablePage({
    super.key,
    required this.child,
    this.edgeStartWidthPx = 24.0,
  });

  final Widget child;
  final double edgeStartWidthPx;

  @override
  State<SwipeablePage> createState() => _SwipeablePageState();
}

class _SwipeablePageState extends State<SwipeablePage> {
  @override
  Widget build(BuildContext context) {
    return _BackSwipeInteractor(
      edgeStartWidthPx: widget.edgeStartWidthPx,
      child: widget.child,
    );
  }
}



class _BackSwipeInteractor extends StatefulWidget {
  const _BackSwipeInteractor({
    required this.child,
    required this.edgeStartWidthPx,
  });
  final Widget child;
  final double edgeStartWidthPx;

  @override
  State<_BackSwipeInteractor> createState() => _BackSwipeInteractorState();
}

class _BackSwipeInteractorState extends State<_BackSwipeInteractor>
    with SingleTickerProviderStateMixin {
  late final _BackSwipeRecognizer _recognizer;
  late final AnimationController _controller;
  late Animation<double> _dxAnim;

  double _dx = 0.0;
  bool _dragging = false;

  // Track left-edge state for horizontal scrollables by depth.
  final Map<int, bool> _horizontalLeftEdgeByDepth = <int, bool>{};
  bool _isAtLeftEdge = false;
  static const double _edgeEpsilonPx = 2.0;
  bool _wasCurrentRoute = false;

  bool _isHorizontal(AxisDirection direction) {
    return direction == AxisDirection.left || direction == AxisDirection.right;
  }

  bool _isPointerInHorizontalScrollable(Offset globalPosition) {
    // Restrict detection to this route's subtree only, so underlying views don't interfere.
    final RenderObject? root = context.findRenderObject();
    if (root == null) return false;
    return _anyHorizontalViewportContains(root, globalPosition);
  }

  bool _isPointerInEditable(Offset globalPosition) {
    final HitTestResult result = HitTestResult();

    WidgetsBinding.instance.hitTestInView(
      result,
      globalPosition,
      View.of(context).viewId,
    );

    for (final entry in result.path) {
      final target = entry.target;

      if (target is RenderEditable) {
        return true;
      }
    }

    return false;
  }

  bool _anyHorizontalViewportContains(
      RenderObject renderObject,
      Offset globalPosition,
      ) {
    // If this render object itself is a horizontal viewport, check if the pointer lies within it.
    if (renderObject is RenderViewport &&
        _isHorizontal(renderObject.axisDirection)) {
      final RenderBox box = renderObject;
      final Offset local = box.globalToLocal(globalPosition);
      if (box.paintBounds.contains(local)) {
        return true;
      }
    }

    bool found = false;
    renderObject.visitChildren((RenderObject child) {
      if (found) return;
      if (_anyHorizontalViewportContains(child, globalPosition)) {
        found = true;
      }
    });
    return found;
  }

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
      setState(() => _dx = _dxAnim.value);
    });
    _recognizer = _BackSwipeRecognizer(
      isEligible: () => _isAtLeftEdge,
      isPointerInHorizontal: _isPointerInHorizontalScrollable,
      isPointerInEditable: _isPointerInEditable,
      edgeStartWidthPx: widget.edgeStartWidthPx,
      onAccepted: () {
        setState(() => _dragging = true);
      },
      onDelta: (deltaDx) {
        if (!_dragging) return;
        setState(() {
          _dx = (_dx + deltaDx).clamp(0.0, MediaQuery.of(context).size.width);
        });
      },
      onEnd: (totalDx, velocity) async {
        final width = MediaQuery.of(context).size.width;
        final shouldPop = velocity > 900 || totalDx > width * 0.50;
        if (shouldPop) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else {
          _dxAnim = Tween(begin: _dx, end: 0.0).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
          _controller.forward(from: 0).whenComplete(() {
            setState(() {
              _dragging = false;
              _dx = 0.0;
            });
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _recognizer.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    if (isCurrentRoute && !_wasCurrentRoute) {
      _horizontalLeftEdgeByDepth.clear();
      _isAtLeftEdge = false;
      _dx = 0.0;
      _dragging = false;
      _wasCurrentRoute = true;
    } else if (!isCurrentRoute && _wasCurrentRoute) {
      _wasCurrentRoute = false;
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;
        if (_isHorizontal(metrics.axisDirection)) {
          final atLeft =
              metrics.pixels <= (metrics.minScrollExtent + _edgeEpsilonPx);
          _horizontalLeftEdgeByDepth[notification.depth] = atLeft;
          // Determine top-most (smallest depth) horizontal scrollable state
          if (_horizontalLeftEdgeByDepth.isNotEmpty) {
            final minDepth = _horizontalLeftEdgeByDepth.keys.reduce(
                  (a, b) => a < b ? a : b,
            );
            final newIsAtLeft = _horizontalLeftEdgeByDepth[minDepth] ?? true;
            if (newIsAtLeft != _isAtLeftEdge) {
              setState(() => _isAtLeftEdge = newIsAtLeft);
            }
          } else if (!_isAtLeftEdge) {
            setState(() => _isAtLeftEdge = true);
          }
        }
        return false; // allow others to receive the notification
      },
      child: IgnorePointer(
        ignoring: !isCurrentRoute,
        child: RawGestureDetector(
          behavior: HitTestBehavior.opaque,
          gestures: {
            _BackSwipeRecognizer:
            GestureRecognizerFactoryWithHandlers<_BackSwipeRecognizer>(
                  () => _recognizer,
                  (instance) {},
            ),
          },
          child: Transform.translate(
            offset: Offset(_dx, 0),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _BackSwipeRecognizer extends OneSequenceGestureRecognizer {
  _BackSwipeRecognizer({
    required this.isEligible,
    required this.isPointerInHorizontal,
    required this.edgeStartWidthPx,
    required this.onAccepted,
    required this.onDelta,
    required this.onEnd,
    required this.isPointerInEditable,
  });

  final bool Function() isEligible;
  final bool Function(Offset globalPosition) isPointerInHorizontal;
  final bool Function(Offset globalPosition) isPointerInEditable;
  final double edgeStartWidthPx;
  final VoidCallback onAccepted;
  final void Function(double deltaDx) onDelta;
  final void Function(double totalDx, double velocity) onEnd;

  Offset? _startGlobal;
  bool _accepted = false;
  double _totalDx = 0.0;
  bool _startedInHorizontal = false;
  bool _startedInEditable = false;
  bool _startedNearLeftEdge = false;
  final VelocityTracker _tracker = VelocityTracker.withKind(
    PointerDeviceKind.touch,
  );

  static const double _minDistance = 0.5; // accept ASAP so PageView won't move

  @override
  void addPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer);
    _startGlobal = event.position;
    _accepted = false;
    _totalDx = 0.0;
    _startedInHorizontal = isPointerInHorizontal(event.position);
    _startedInEditable = isPointerInEditable(event.position);
    _startedNearLeftEdge = event.position.dx <= edgeStartWidthPx;
    _tracker.addPosition(event.timeStamp, event.position);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      _tracker.addPosition(event.timeStamp, event.position);
      if (_startGlobal == null) return;
      final delta = event.position - _startGlobal!;
      final dx = delta.dx;
      final dy = delta.dy.abs();

      if (!_accepted) {
        final movedEnough = delta.distance >= _minDistance;
        final isRight = dx > 0;
        final horizontalDominant = dx.abs() > dy * 1.2;
        final eligibleNow = _startedInEditable
            ? _startedNearLeftEdge
            : (_startedNearLeftEdge || (!_startedInHorizontal || isEligible()));

        if (movedEnough && isRight && horizontalDominant && eligibleNow) {
          _accepted = true;
          resolve(GestureDisposition.accepted);
          onAccepted();
        } else if (movedEnough && !isRight) {
          final insideHorizontal = _startedInHorizontal;
          if (!insideHorizontal && horizontalDominant) {
            _accepted = true;
            resolve(GestureDisposition.accepted);
          } else {
            resolve(GestureDisposition.rejected);
            stopTrackingPointer(event.pointer);
          }
        }
      }

      if (_accepted) {
        _totalDx += event.delta.dx;
        onDelta(event.delta.dx);
      }
    } else if (event is PointerUpEvent) {
      final vx = _tracker.getVelocity().pixelsPerSecond.dx;
      if (_accepted) {
        onEnd(_totalDx, vx);
      }
      stopTrackingPointer(event.pointer);
      _accepted = false;
      _startGlobal = null;
      _totalDx = 0.0;
      _startedInHorizontal = false;
      _startedNearLeftEdge = false;
    } else if (event is PointerCancelEvent) {
      stopTrackingPointer(event.pointer);
      _accepted = false;
      _startGlobal = null;
      _totalDx = 0.0;
      _startedInHorizontal = false;
      _startedNearLeftEdge = false;
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  void acceptGesture(int pointer) {}

  @override
  void rejectGesture(int pointer) {}

  @override
  String get debugDescription => 'BackSwipe';
}
