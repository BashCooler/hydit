import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:hydrus_flutter/core/data/hydrus.dart';
import 'package:hydrus_flutter/core/ui/getx/controllers.dart';
import 'package:hydrus_flutter/core/ui/widget/images.dart';
import '../getx/controllers.dart';


class ViewFile extends StatelessWidget {
  final int index;

  const ViewFile(this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    final file = Get.find<Images>().$[index];
    switch (file.type) {
      case 'image':
        return ViewImage(index);
      case 'video':
        return ViewVideo(index);
      case _:
        return _NotSupported(file.type);
    }
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
      enabled: controller.i == index,
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
    return Center(
      child: ObxHero(
        index: index,
        tag: image.id,
        child: HighResImage(image: image),
      ),
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
    final id = images.images[widget.index].id;
    player.open(
      Media(client.buildImageUrl(id)),
      play: pageController.i == widget.index,
    );
    player.stream.buffer.listen((duration) {
      if (!ready && duration > Duration(milliseconds: 500)) {
        setState(() => ready = true);
      }
    });
  }

  @override
  void dispose() async {
    super.dispose();
    await player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Auto play/pause on page change
    ever(pageController.index, (i) {
      if (i != widget.index) {
        player.pause();
        player.seek(Duration.zero);
      } else {
        player.play();
      }
    });
    // Get video parameters
    var video = images.images[widget.index];
    double width = video.width.toDouble();
    double height = video.height.toDouble();
    double aspectRatio = width/height;
    // Build widget
    return Center(
      child: Obx(() => HeroMode(
        enabled: widget.index == pageController.i,
        child: Hero(
          tag: video.id,
          createRectTween: (begin, end) => RectTween(begin: begin, end: end),
          child: ImageStack(
            aspectRatio: aspectRatio,
            children: [
              CachedNetworkImage(
                imageUrl: client.buildImageUrl(video.id, thumbnail: true),
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
      )),
    );
  }
}


class _NotSupported extends StatelessWidget {
  final String? type;

  const _NotSupported(this.type);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Error: media type "$type" is unsupported'),
    );
  }
}