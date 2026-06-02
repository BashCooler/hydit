import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/core/states/file.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:hydit/core/services/repo.dart';

import '../getx/page.dart';
import 'seekbar.dart';
import 'views.dart';


class ViewVideo extends StatefulWidget {
  final int index;
  final String tag;
  final HydrusFile file;

  const ViewVideo({
    super.key,
    required this.index,
    required this.tag,
    required this.file,
  });

  @override
  State<ViewVideo> createState() => _ViewVideoState();
}

class _ViewVideoState extends State<ViewVideo> {
  late final player = Player(configuration: PlayerConfiguration())
    ..setVolume(0.0);
  late final controller = VideoController(player);

  final repo = Get.find<Repo>();
  late final PageGetxController pageController;

  StreamSubscription<Duration>? _bufferSubscription;
  Worker? _pageChangeWorker;
  bool _disposed = false;

  bool ready = false;

  @override
  void initState() {
    super.initState();
    pageController = Get.find(tag: widget.tag);
    unawaited(
      player.open(
        Media(repo.buildUrl(widget.file.id)),
        play: pageController.enabled(widget.index),
      ).catchError((_) {}),
    );
    _bufferSubscription = player.stream.buffer.listen(playWhenLoaded);
    setPageChangeListener();
  }

  void playWhenLoaded(Duration d) {
    if (ready) return;
    if (d < Duration(milliseconds: 500)) return;
    if (mounted) setState(() => ready = true);
  }

  void setPageChangeListener() {
    _pageChangeWorker = ever<int>(pageController.index, (i) {
      if (_disposed) return;
      if (i == widget.index) {
        _usePlayer(player.play);
      } else {
        _usePlayer(player.pause);
        _usePlayer(() => player.seek(Duration.zero));
      }
    });
  }

  void _usePlayer(Future<void> Function() action) {
    if (_disposed) return;
    try {
      unawaited(action().catchError((_) {}));
    } on AssertionError {
      // media_kit can assert if a late page-change
      // callback reaches a disposed player.
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _pageChangeWorker?.dispose();
    unawaited(_bufferSubscription?.cancel());
    unawaited(player.dispose().catchError((_) {}));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ObxHero(
      index: widget.index,
      heroTag: widget.file.id,
      getTag: widget.tag,
      child: Stack(
        fit: .expand,
        children: [
          CachedNetworkImage(
            imageUrl: repo.buildUrl(widget.file.id, thumbnail: true),
            placeholder: (context, url) => SizedBox.shrink(),
            fit: .contain,
          ),
          AnimatedOpacity(
            opacity: ready ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInQuint,
            child: VideoPlayer(controller: controller, tag: widget.tag),
          ),
        ],
      ),
    );
  }
}


class VideoPlayer extends StatelessWidget {
  final String tag;
  final VideoController controller;

  const VideoPlayer({super.key, required this.controller, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Video(
      fit: .contain,
      controller: controller,
      fill: Colors.transparent,
      controls: (state) {
        return AnimatedControlsPadding(
          tag: tag,
          child: const Column(
            mainAxisAlignment: .end,
            children: [
              MaterialPositionIndicator(),
              Row(
                crossAxisAlignment: .center,
                children: [
                  Padding(
                    padding: .only(left: 12),
                    child: MaterialPlayOrPauseButton(),
                  ),
                  CustomMaterialSeekBar(),
                  // MaterialFullscreenButton(),
                  MaterialDesktopVolumeButton(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}


class AnimatedControlsPadding extends StatelessWidget {
  final String tag;
  final Widget child;

  const AnimatedControlsPadding({super.key, required this.tag, required this.child});

  @override
  Widget build(BuildContext context) {
    final PageGetxController page = Get.find(tag: tag);
    final viewPadding = Get.mediaQuery.viewPadding.bottom;
    final padding = Get.mediaQuery.padding.bottom;

    return Obx(() {
      final inverseProgress = (1 - page.sheetProgress.value);
      return Padding(
        padding: .only(bottom: inverseProgress * (viewPadding + padding)),
        child: Material(
          color: Colors.transparent,
          child: child,
        ),
      );
    });
  }
}
