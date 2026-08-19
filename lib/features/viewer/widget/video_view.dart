import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/services/services.dart';

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
        CachedNetworkImage(
          imageUrl: file.thumbnailUrl,
          placeholder: (context, url) => placeholder,
          fit: .contain,
        ),
        Obx(() {
          if (page.i != index) {
            return placeholder;
          }

          return AnimatedOpacity(
            duration: 150.ms,
            opacity: video.ready ? 1 : 0,
            child: Video(
              fit: .contain,
              controller: video.controller,
              fill: Colors.transparent,
              controls: NoVideoControls,
            ),
          );
        }),
      ],
    );
  }
}


class VideoControls extends StatelessWidget {
  final Player player;

  const VideoControls({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .fromLTRB(8, 0, 8, 0),
      height: 60,
      child: Column(
        children: [
          PositionIndicator(player: player),
          Row(
            crossAxisAlignment: .center,
            children: [
              PlayOrPauseButton(player: player),
              Expanded(
                child: SeekBar(player: player),
              ),
              VolumeButton(player: player),
            ],
          ),
        ],
      ),
    );
  }
}


class PositionIndicator extends HookWidget {
  final Player player;

  const PositionIndicator({super.key, required this.player});

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

    return Text(
      '${pos.label(reference: dur)} / ${dur.label(reference: dur)}',
      style: TextStyle(
        height: 1.0,
        fontSize: 12.0,
      ),
    );
  }
}


class PlayOrPauseButton extends HookWidget {
  final Player player;

  const PlayOrPauseButton({super.key, required this.player});

  @override
  Widget build(BuildContext context) {

    final playing = useStream(
      player.stream.playing,
      initialData: player.state.playing,
    ).requireData;

    final controller = useAnimationController(
      duration: 200.ms,
    );

    useEffect(() {
      if (playing) {
        controller.forward();
      } else {
        controller.reverse();
      }
      return null;
    }, [playing]);

    return IconButton(
      onPressed: player.playOrPause,
      icon: AnimatedIcon(
        icon: AnimatedIcons.play_pause,
        progress: controller,
      ),
    );
  }
}



class SeekBar extends HookWidget {
  final Player player;

  const SeekBar({super.key, required this.player});

  double progress(Duration pos, Duration dur, {
    double? seekPos,
  }) {
    return seekPos
        .or(pos.inMilliseconds / dur.inMilliseconds)
        .clamp(0, 1);
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

    final shouldResume = useRef(true);

    final pending = useRef(false);

    return SizedBox(
      height: 48,
      child: SliderTheme(
        data: const SliderThemeData(
          padding: .zero,
          trackHeight: 2.4,
          trackShape: RectangularSliderTrackShape(),
          thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: 6.4,
            elevation: 0,
            pressedElevation: 0,
          ),
        ),
        child: Slider(
          value: progress(pos, dur, seekPos: seekPos.value),
          secondaryTrackValue: progress(buf, dur),
          min: 0,
          max: 1,
          onChangeStart: (value) {
            shouldResume.value = player.state.playing;
            player.pause();
          },
          onChangeEnd: (value) async {
            await player.seek(dur * value);
            if (shouldResume.value) await player.play();
            WidgetsBinding.instance
                .addPostFrameCallback((_) => seekPos.value = null);
          },
          onChanged: (value) {
            seekPos.value = value;
            if (!pending.value) {
              player.seek(dur * value).loading(pending);
            }
          },
        ),
      ),
    );
  }
}


class VolumeButton extends HookWidget {
  final Player player;

  const VolumeButton({super.key, required this.player});

  @override
  Widget build(BuildContext context) {

    final volume = useStream(
      player.stream.volume,
      initialData: player.state.volume,
    ).requireData;

    return IconButton(
      onPressed: () => switch (volume) {
        0 => player.setVolume(100),
        _ => player.setVolume(0),
      },
      icon: switch (volume) {
        0 => const Icon(Icons.volume_off),
        _ => const Icon(Icons.volume_up),
      },
    );
  }
}
