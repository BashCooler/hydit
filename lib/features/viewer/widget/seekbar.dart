import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/material.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/widgets/fullscreen_inherited_widget.dart';


/// [MaterialVideoControlsThemeData] available in this [context].
MaterialVideoControlsThemeData _theme(BuildContext context) =>
    FullscreenInheritedWidget.maybeOf(context) == null
        ? MaterialVideoControlsTheme.maybeOf(context)?.normal ??
        kDefaultMaterialVideoControlsThemeData
        : MaterialVideoControlsTheme.maybeOf(context)?.fullscreen ??
        kDefaultMaterialVideoControlsThemeDataFullscreen;


/// Material design seek bar.
class CustomMaterialSeekBar extends StatefulWidget {
  final ValueNotifier<Duration>? delta;
  final VoidCallback? onSeekStart;
  final VoidCallback? onSeekEnd;

  const CustomMaterialSeekBar({
    super.key,
    this.delta,
    this.onSeekStart,
    this.onSeekEnd,
  });

  @override
  CustomMaterialSeekBarState createState() => CustomMaterialSeekBarState();
}

class CustomMaterialSeekBarState extends State<CustomMaterialSeekBar> {
  bool tapped = false;
  double slider = 0.0;

  late bool playing = controller(context).player.state.playing;
  late Duration position = controller(context).player.state.position;
  late Duration duration = controller(context).player.state.duration;
  late Duration buffer = controller(context).player.state.buffer;

  final List<StreamSubscription> subscriptions = [];

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void listener() {
    setState(() {
      final delta = widget.delta?.value ?? Duration.zero;
      position = controller(context).player.state.position + delta;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.delta?.addListener(listener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (subscriptions.isEmpty && widget.delta == null) {
      subscriptions.addAll(
        [
          controller(context).player.stream.playing.listen((event) {
            setState(() {
              playing = event;
            });
          }),
          controller(context).player.stream.completed.listen((event) {
            setState(() {
              position = Duration.zero;
            });
          }),
          controller(context).player.stream.position.listen((event) {
            setState(() {
              if (!tapped) {
                position = event;
              }
            });
          }),
          controller(context).player.stream.duration.listen((event) {
            setState(() {
              duration = event;
            });
          }),
          controller(context).player.stream.buffer.listen((event) {
            setState(() {
              buffer = event;
            });
          }),
        ],
      );
    }
  }

  @override
  void dispose() {
    widget.delta?.removeListener(listener);
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  void onPointerMove(PointerMoveEvent e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      tapped = true;
      slider = percent.clamp(0.0, 1.0);
    });
    controller(context).player.seek(duration * slider);
  }

  void onPointerDown() {
    widget.onSeekStart?.call();
    setState(() {
      tapped = true;
    });
  }

  void onPointerUp() {
    widget.onSeekEnd?.call();
    setState(() {
      // Explicitly set the position to prevent the slider from jumping.
      tapped = false;
      position = duration * slider;
    });
    controller(context).player.seek(duration * slider);
  }

  void onPanStart(DragStartDetails e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      tapped = true;
      slider = percent.clamp(0.0, 1.0);
    });
  }

  void onPanDown(DragDownDetails e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      tapped = true;
      slider = percent.clamp(0.0, 1.0);
    });
  }

  void onPanUpdate(DragUpdateDetails e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      tapped = true;
      slider = percent.clamp(0.0, 1.0);
    });
  }

  /// Returns the current playback position in percentage.
  double get positionPercent {
    if (position == Duration.zero || duration == Duration.zero) {
      return 0.0;
    } else {
      final value = position.inMilliseconds / duration.inMilliseconds;
      return value.clamp(0.0, 1.0);
    }
  }

  /// Returns the current playback buffer position in percentage.
  double get bufferPercent {
    if (buffer == Duration.zero || duration == Duration.zero) {
      return 0.0;
    } else {
      final value = buffer.inMilliseconds / duration.inMilliseconds;
      return value.clamp(0.0, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        clipBehavior: Clip.none,
        margin: _theme(context).seekBarMargin,
        child: LayoutBuilder(
          builder: (context, constraints) => MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onHorizontalDragUpdate: (_) {},
              onPanStart: (e) => onPanStart(e, constraints),
              onPanDown: (e) => onPanDown(e, constraints),
              onPanUpdate: (e) => onPanUpdate(e, constraints),
              child: Listener(
                onPointerMove: (e) => onPointerMove(e, constraints),
                onPointerDown: (e) => onPointerDown(),
                onPointerUp: (e) => onPointerUp(),
                child: Container(
                  color: Colors.transparent,
                  width: constraints.maxWidth,
                  alignment: .centerLeft, // Edited
                  height: _theme(context).seekBarContainerHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: constraints.maxWidth,
                        height: _theme(context).seekBarHeight,
                        alignment: Alignment.bottomLeft,
                        color: _theme(context).seekBarColor,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomLeft,
                          children: [
                            Container(
                              width: constraints.maxWidth * bufferPercent,
                              color: _theme(context).seekBarBufferColor,
                            ),
                            Container(
                              width: tapped
                                  ? constraints.maxWidth * slider
                                  : constraints.maxWidth * positionPercent,
                              color: Theme.of(context).colorScheme.primary, // Edited
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: tapped
                            ? (constraints.maxWidth -
                            _theme(context).seekBarThumbSize / 2) *
                            slider
                            : (constraints.maxWidth -
                            _theme(context).seekBarThumbSize / 2) *
                            positionPercent,
                        bottom: -1.0 * _theme(context).seekBarThumbSize / 2 +
                            _theme(context).seekBarHeight / 2,
                        child: Container(
                          width: _theme(context).seekBarThumbSize,
                          height: _theme(context).seekBarThumbSize,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary, // Edited
                            borderRadius: BorderRadius.circular(
                              _theme(context).seekBarThumbSize / 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}