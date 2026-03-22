import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:hydrus_flutter/core/data/hydrus.dart';
import 'package:hydrus_flutter/core/logic/entities.dart';
import 'package:hydrus_flutter/core/ui/getx/controllers.dart';
import '../../../features/viewer/getx/controllers.dart';


class Thumbnail extends StatelessWidget {
  final HydrusImage image;

  const Thumbnail(this.image, {super.key});

  @override
  Widget build(BuildContext context) {
    final client = Get.find<Client>();
    return AspectRatio(
      aspectRatio: 1.0,
      child: CachedNetworkImage(
        imageUrl: client.buildImageUrl(image.id, thumbnail: true),
        placeholder: (context, url) => ColoredBox(color: Colors.white10),
        fit: .cover,
      ),
    );
  }
}


class HighResImage extends StatelessWidget {
  final HydrusImage image;

  const HighResImage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final client = Get.find<Client>();
    final aspectRatio = image.width/image.height;
    return ImageStack(
      aspectRatio: aspectRatio,
      children: [
        CachedNetworkImage(
          imageUrl: client.buildImageUrl(image.id, thumbnail: true),
          placeholder: (_, _) => SizedBox.shrink(),
          fit: .cover,
        ),
        CachedNetworkImage(
          imageUrl: client.buildImageUrl(image.id),
          placeholder: (_, _) => SizedBox.shrink(),
          fit: .cover,
        ),
      ],
    );
  }
}


class ImageStack extends StatelessWidget {
  final double aspectRatio;
  final List<Widget> children;

  const ImageStack({
    super.key,
    required this.aspectRatio,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: children,
      ),
    );
  }
}


/// To make sure the next image is ready we need to preload
/// next/previous images.
///
/// ```dart
/// PageView.allowImplicitScrolling = true
/// ```
///
/// Hero tries to animate them as well, so we need to explicitly tell it
/// not to by comparing the **true** [index] of the image we're looking
/// at with the [builderIndex] provided by the item builder.
///
/// ```dart
/// itemBuilder: (context, index)
///                          ↑
///               This is builderIndex
/// ```
class ViewImage extends StatelessWidget {
  final ZoomController zoomCtrl;
  final int index;
  final int builderIndex;

  ViewImage(this.zoomCtrl, this.index, this.builderIndex, {super.key});

  final imgCtrl = Get.find<Images>();

  @override
  Widget build(BuildContext context) {
    final images = imgCtrl.images;
    return GestureDetector(
      onDoubleTapDown: (TapDownDetails details) {
        zoomCtrl.handleDoubleTap(details.localPosition);
      },
      child: InteractiveViewer(
        minScale: zoomCtrl.minScale,
        maxScale: zoomCtrl.maxScale,
        transformationController: zoomCtrl.transformationCtrl,
        child: Center(
          child: HeroMode(
            enabled: index == builderIndex,
            child: Hero(
              tag: images[builderIndex].id,
              createRectTween: (begin, end) {  // linear transition
                return RectTween(begin: begin, end: end);
              },
              child: HighResImage(image: images[builderIndex]),
            ),
          ),
        ),
      ),
    );
  }
}


class ViewVideo extends StatefulWidget {
  final int index;
  final int builderIndex;
  final PageGetxController pageViewController;

  const ViewVideo(this.pageViewController, this.index, this.builderIndex, {super.key});

  @override
  State<ViewVideo> createState() => _ViewVideoState();
}

class _ViewVideoState extends State<ViewVideo> {

  late final player = Player(configuration: PlayerConfiguration())
    ..setVolume(0.0);
  late final controller = VideoController(player);

  final imgCtrl = Get.find<Images>();
  final client = Get.find<Client>();

  bool ready = false;

  @override
  void initState() {
    super.initState();
    final id = imgCtrl.images[widget.builderIndex].id;
    player.open(
      Media(client.buildImageUrl(id)),
      play: widget.index == widget.builderIndex,
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
    final pageCtrl = widget.pageViewController;
    ever(pageCtrl.index, (i) {
      if (i != widget.builderIndex) {
        player.pause();
        player.seek(Duration.zero);
      } else {
        player.play();
      }
    });
    // Get video parameters
    var video = imgCtrl.images[widget.builderIndex];
    double width = video.width.toDouble();
    double height = video.height.toDouble();
    double aspectRatio = width/height;
    // Build widget
    return Center(
      child: HeroMode(
        enabled: widget.builderIndex == widget.index,
        child: Hero(
          tag: video.id,
          createRectTween: (begin, end) {
            return RectTween(begin: begin, end: end);
          },
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
      ),
    );
  }
}