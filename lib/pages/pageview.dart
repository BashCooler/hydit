import 'dart:developer';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:flutter/material.dart';
import 'package:hydrus_flutter/api/hydrus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrus_flutter/widgets/images.dart';

import '../main.dart';


class ImageView extends StatefulWidget {
  final List<HydrusImage> images;
  final int index;
  final Client client;
  final GridObserverController observerController;

  const ImageView({
    super.key,
    required this.images,
    required this.index,
    required this.client,
    required this.observerController,
  });

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> with TickerProviderStateMixin {
  late final PageController _pageController;

  final _transformationController = TransformationController();
  double get _interactiveViewerScale => _transformationController.value.row0.x;

  bool _isZoomed = false, _isMultitouch = false;
  final List<int> _pointerEvents = [];

  final double _minScale = 1.0, _maxScale = 4.0;

  late Offset _doubleTapLocalPosition;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addListener(() {
      // listen matrix4 changed, if not, set as default value
      _transformationController.value = _animation?.value ?? Matrix4.identity();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _transformationController.dispose();
    _pageController.dispose();
    _animationController.dispose();
  }

  /// Takes details of [PointerDownEvent] or [PointerUpEvent].
  /// Adds/removes the event to/from the [List] of type [int].
  /// Determines whether a multitouch is being used, updates
  /// the [bool] [_isMultitouch] variable with [SetState].
  void registerPointerEventState(Object details) {
    if (details is PointerDownEvent) {
      _pointerEvents.add(details.pointer);
    }
    if (details is PointerUpEvent) {
      _pointerEvents.remove(details.pointer);
    }
    if (_interactiveViewerScale > 1.0) return;

    final newValue = _pointerEvents.length > 1;
    if (newValue != _isMultitouch) {
      setState(() => _isMultitouch = newValue);
    }
  }

  void handleDoubleTap() {
    Matrix4 mat = _transformationController.value.clone();
    final double currentScale = mat.row0.x;
    double targetScale = (currentScale <= _minScale) ? _maxScale : _minScale;
    setState(() => _isZoomed = targetScale > 1.0);
    final double offSetX = targetScale == _minScale
        ? 0.0
        : -_doubleTapLocalPosition.dx * (targetScale - 1);
    final double offSetY = targetScale == _minScale
        ? 0.0
        : -_doubleTapLocalPosition.dy * (targetScale - 1);
    mat = getTargetMatrix(targetScale, mat, offSetX, offSetY);
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: mat,
    ).animate(CurveTween(curve: Curves.easeOut).animate(_animationController));
    _animationController.forward(from: 0);
  }

  /// Jumps to corresponding item in [GridView].
  ///
  /// Example: you open item `0` in the [GridView], then scroll to file `40`
  /// using [PageView]. [jumpToPageInBackground] scrolls to picture `40` in
  /// the background to lazy load new thumbnails and so when you close
  /// [PageView] you end up seeing item `40`, not `0`.
  ///
  /// TODO `-2` in `page - 2` is a tech debt!
  /// If [SliverGridDelegateWithFixedCrossAxisCount.crossAxisCount] changed
  /// in settings the `-2` offset becomes irrelevant
  void jumpToPageInBackground(int page) {
    widget.observerController.jumpTo(index: page - 2 > 0 ? page - 2 : 0);
  }

  // MARK: BUILD

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (closed, object) {
        WidgetsBinding.instance.addPostFrameCallback((_) => context.read<SearchVisibilityCubit>().show());
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: Listener(
          onPointerDown: registerPointerEventState,
          onPointerUp: registerPointerEventState,
          child: PageView.builder(
            onPageChanged: jumpToPageInBackground,
            physics: (_isMultitouch || _isZoomed)
                ? const NeverScrollableScrollPhysics()
                : const SnappyPageScrollPhysics(),
            controller: _pageController,
            itemCount: widget.images.length,
            itemBuilder: (context, i) {
              return GestureDetector(
                onDoubleTapDown: (TapDownDetails details) {
                  _doubleTapLocalPosition = details.localPosition;
                },
                onDoubleTap: handleDoubleTap,
                child: InteractiveViewer(
                  minScale: _minScale,
                  maxScale: _maxScale,
                  transformationController: _transformationController,
                  child: Center(
                    child: Hero(
                      tag: widget.images[i].id,
                      createRectTween: (begin, end) {  // linear transition
                        return RectTween(begin: begin, end: end);
                      },
                      child: HighResImage(
                        image: widget.images[i],
                        client: widget.client,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          // Swipe doesn't work on Windows for some reason so I added buttons
          child: BottomAppBarActions(pageController: _pageController),
        ),
      ),
    );
  }
}


class BottomAppBarActions extends StatelessWidget {
  const BottomAppBarActions({
    super.key,
    required PageController pageController,
  }) : _pageController = pageController;

  final PageController _pageController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        IconButton(
          onPressed: () => _pageController.previousPage(
            duration: Duration(milliseconds: 150),
            curve: Curves.decelerate,
          ),
          icon: Icon(Icons.keyboard_arrow_left),
        ),
        IconButton(
          onPressed: () => _pageController.nextPage(
            duration: Duration(milliseconds: 150),
            curve: Curves.decelerate,
          ),
          icon: Icon(Icons.keyboard_arrow_right),
        ),
      ],
    );
  }
}


// MARK: TARGET MATRIX

/// Returns target transformation matrix.
///
/// Initial transformation matrix is an identity matrix.
///
/// Target matrix with 4x scale and X1=-500, Y1=-800 offset:
/// ```
/// 4 0 0 -500
/// 0 4 0 -800
/// 0 0 4 0
/// 0 0 0 1
/// ```
Matrix4 getTargetMatrix(double targetScale, Matrix4 mat, double offSetX, double offSetY) {
  return Matrix4.fromList([
    // Column 1
    targetScale,  // scale X
    mat.row1.x,
    mat.row2.x,
    mat.row3.x,
    // Column 2
    mat.row0.y,
    targetScale,  // scale Y
    mat.row2.y,
    mat.row3.y,
    // Column 3
    mat.row0.z,
    mat.row1.z,
    targetScale,  // scale Z
    mat.row3.z,
    // Column 4
    offSetX,      // translate X1
    offSetY,      // translate Y1
    mat.row2.w,
    mat.row3.w,
  ]);
}


/// Makes [PageView] scroll more responsive. Still not perfect.
class SnappyPageScrollPhysics extends PageScrollPhysics {
  const SnappyPageScrollPhysics({super.parent});

  @override
  SnappyPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SnappyPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
    mass: 1,
    stiffness: 250,
    damping: 30,
  );
}