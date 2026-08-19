import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hydit/features/viewer/widget/views.dart';
import 'package:hydit/services/services.dart';
import 'package:hydit/utils/utils.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';

import 'package:hydit/reactive/file.dart';

import '../getx/page.dart';
import '../getx/sheet.dart';
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

  VideoGetxController get video => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final theme = MaterialVideoControlsThemeData(
      seekBarAlignment: .center,
      seekBarPositionColor: primary,
      seekBarThumbColor: primary,
    );

    return Video(
      fit: .contain,
      controller: controller,
      fill: Colors.transparent,
      controls: (state) {
        return MaterialVideoControlsTheme(
          normal: theme,
          fullscreen: theme,
          child: AnimatedControlsPadding(
            tag: tag,
            child: Column(
              mainAxisAlignment: .end,
              children: [
                const MaterialPositionIndicator(),
                const Row(
                  crossAxisAlignment: .center,
                  children: [
                    Padding(
                      padding: .only(left: 12),
                      child: MaterialPlayOrPauseButton(),
                    ),
                    Expanded(
                      child: MaterialSeekBar(),
                    ),
                    // MaterialFullscreenButton(),
                    MaterialDesktopVolumeButton(),
                  ],
                ),
                SeekBar(player: video.controller.player),
              ],
            ),
          ),
        );
      },
    );
  }
}


class SeekBar extends HookWidget {
  final Player player;

  const SeekBar({super.key, required this.player});

  double progress(Duration pos, Duration dur) {
    return pos.inMilliseconds / dur.inMilliseconds;
  }

  @override
  Widget build(BuildContext context) {

    final pos = useStream(
      player.stream.position,
      initialData: player.state.position,
    ).requireData;

    final dur = useStream(
      player.stream.duration,
      initialData: player.state.duration,
    ).requireData;

    final buf = useStream(
      player.stream.buffer,
      initialData: player.state.buffer,
    ).requireData;

    final seekPos = useState<double?>(null);

    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 2.4,
        trackShape: RectangularSliderTrackShape(),
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: 6.4,
          elevation: 0,
          pressedElevation: 0,
        ),
      ),
      child: Slider(
        value: seekPos.value ?? progress(pos, dur),
        secondaryTrackValue: progress(buf, dur),
        min: 0,
        max: 1,
        onChangeEnd: (value) {
          seekPos.value = null;
        },
        onChanged: (value) {
          seekPos.value = value;
        },
      ),
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

  SheetController get sheet => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    final viewPadding = mq.viewPadding.bottom;
    final padding = mq.padding.bottom;

    return Obx(() {
      final inverseProgress = (1 - sheet.progress.value);
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
