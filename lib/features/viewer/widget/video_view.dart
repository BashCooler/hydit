import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hydit/features/viewer/widget/views.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';

import 'package:hydit/reactive/file.dart';
import 'package:hydit/features/viewer/widget/seekbar.dart';

import '../getx/page.dart';
import '../getx/video.dart';


class VideoView extends StatelessWidget {
  final String tag;
  final int index;
  final HydrusFile file;

  const VideoView({
    super.key,
    required this.index,
    required this.tag,
    required this.file,
  });

  static const placeholder = SizedBox.shrink();

  PageGetxController get page => Get.find(tag: tag);
  VideoGetxController get video => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: .center,
      children: [
        ObxHero(
          index: index,
          tag: file.id,
          page: page,
          child: CachedNetworkImage(
            imageUrl: file.thumbnailUrl,
            placeholder: (context, url) => placeholder,
            fit: .contain,
          ),
        ),
        Obx(() {
          if (page.i != index) {
            return placeholder;
          }

          return AnimatedOpacity(
            duration: 150.ms,
            opacity: video.ready ? 1 : 0,
            child: VideoPlayer(
              controller: video.controller,
              tag: tag,
            ),
          );
        }),
      ],
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

  const AnimatedControlsPadding({
    super.key,
    required this.tag,
    required this.child,
  });

  PageGetxController get page => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    final viewPadding = mq.viewPadding.bottom;
    final padding = mq.padding.bottom;

    return Obx(() {
      final inverseProgress = (1 - page.sheetProgress.value);
      final bottom = inverseProgress * (viewPadding + padding);

      return Padding(
        padding: .only(bottom: bottom),
        child: Material(
          color: Colors.transparent,
          child: child,
        ),
      );
    });
  }
}
