import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydrus_flutter/features/viewer/getx/transform.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:hydrus_flutter/core/data/hydrus.dart';
import 'package:hydrus_flutter/core/ui/widget/images.dart';
import 'package:hydrus_flutter/core/ui/getx/controllers.dart';
import '../getx/page.dart';


class ViewFile extends StatelessWidget {
  final int index;

  const ViewFile(this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    final file = Get.find<Images>().$[index];
    return switch (file.type) {
      'image' => ViewImage(index),
      'video' => ViewVideo(index),
      _ => _NotSupported(file.type),
    };
  }
}


class ObxHero extends StatelessWidget {
  final int index;
  final Object tag;
  final Widget child;

  const ObxHero({super.key, required this.index, required this.tag, required this.child});

  @override
  Widget build(BuildContext context) {
    final PageGetxController controller = Get.find();
    return Obx(() => HeroMode(
      enabled: controller.enabled(index),
      child: Hero(
        tag: tag,
        createRectTween: (b, e) => RectTween(begin: b, end: e),
        child: child,
      ),
    ));
  }
}


class ViewImage extends StatelessWidget {
  final int index;

  const ViewImage(this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    final image = Get.find<Images>().$[index];
    final TransformController transform = Get.find();
    return GestureDetector(
      onDoubleTapDown: transform.handleDoubleTap,
      child: Obx(() => InteractiveViewer(
        minScale: transform.minScale,
        maxScale: transform.maxScale,
        panEnabled: !transform.blockViewer.value,
        transformationController: transform.$,
        child: Center(
          child: ObxHero(
            index: index,
            tag: image.id,
            child: HighResImage(image: image),
          ),
        ),
      )),
    );
  }
}


class ViewVideo extends StatefulWidget {
  final int index;

  const ViewVideo(this.index, {super.key});

  @override
  State<ViewVideo> createState() => _ViewVideoState();
}

class _ViewVideoState extends State<ViewVideo> {

  late final player = Player(configuration: PlayerConfiguration())
    ..setVolume(0.0);
  late final controller = VideoController(player);

  final images = Get.find<Images>();
  final client = Get.find<Client>();
  final pageController = Get.find<PageGetxController>();

  bool ready = false;

  @override
  void initState() {
    super.initState();
    final id = images.$[widget.index].id;
    player.open(
      Media(client.buildUrl(id)),
      play: pageController.enabled(widget.index),
    );
    player.stream.buffer.listen(playWhenLoaded);
    setPageChangeListener();
  }

  void playWhenLoaded(Duration d) {
    if (ready) return;
    if (d < Duration(milliseconds: 500)) return;
    setState(() => ready = true);
  }

  void setPageChangeListener() => ever(pageController.index, (i) {
    if (i == widget.index) {
      player.play();
    } else {
      player.pause();
      player.seek(Duration.zero);
    }
  });

  @override
  void dispose() async {
    super.dispose();
    await player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var video = images.$[widget.index];
    return Center(
      child: ObxHero(
        index: widget.index,
        tag: video.id,
        child: ImageStack(
          aspectRatio: video.width /video.height,
          children: [
            CachedNetworkImage(
              imageUrl: client.buildUrl(video.id, thumbnail: true),
              placeholder: (context, url) => SizedBox.shrink(),
              fit: .cover,
            ),
            AnimatedOpacity(
              opacity: ready ? 1 : 0,
              duration: Duration(milliseconds: 150),
              curve: Curves.easeInQuint,
              child: Video(
                controller: controller,
                fill: Colors.transparent,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _NotSupported extends StatelessWidget {
  final String? type;

  const _NotSupported(this.type);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: .center,
      spacing: 15,
      children: [
        Icon(Icons.image_not_supported_outlined, size: 96),
        Text('Media type "$type" is unsupported'),
      ],
    );
  }
}