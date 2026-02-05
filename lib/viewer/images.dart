import 'dart:developer';

import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:hydrus_flutter/api/hydrus.dart';
import 'package:hydrus_flutter/gallery/services.dart';
import 'controllers.dart';


class HydrusImage {
  final int id;
  Uint8List? low;
  Uint8List? high;
  int? width, height;
  String? mime;
  int? duration;
  Map<String, dynamic>? tags;

  HydrusImage(this.id);
}


class Thumbnail extends StatelessWidget {
  final HydrusImage image;
  final client = Get.find<Client>();

  final BoxFit _boxFit = BoxFit.cover;
  static const double _aspectRatio = 1.0;

  Thumbnail(this.image, {super.key});

  @override
  Widget build(BuildContext context) {

    if (image.low != null) {
      return ImageStack(
        aspectRatio: _aspectRatio,
        children: [Image.memory(image.low!, fit: _boxFit)],
      );
    }

    return FutureBuilder(
      future: client.getThumbnail(image.id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          image.low = snapshot.data;
          return ImageStack(
            aspectRatio: _aspectRatio,
            children: [Image.memory(snapshot.data!, fit: _boxFit)],
          );
        }
        else {
          return const ColoredBox(color: Colors.white10);
        }
      },
    );
  }
}


class HighResImage extends StatelessWidget {
  final HydrusImage image;
  final client = Get.find<Client>();

  final BoxFit _boxFit = BoxFit.cover;

  HighResImage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {

    double width = image.width!.toDouble();
    double height = image.height!.toDouble();
    double aspectRatio = width/height;

    if (image.high != null) {
      return ImageStack(
        aspectRatio: aspectRatio,
        children: [
          Image.memory(image.low!, fit: _boxFit),
          Image.memory(image.high!, fit: _boxFit),
        ],
      );
    }

    return FutureBuilder<Uint8List>(
      future: client.getFile(image.id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          image.high = snapshot.data;
          return ImageStack(
            aspectRatio: aspectRatio,
            children: [
              Image.memory(image.low!, fit: _boxFit),
              Image.memory(snapshot.data!, fit: _boxFit),
            ],
          );
        }
        else {
          return ImageStack(
            aspectRatio: aspectRatio,
            children: [Image.memory(image.low!, fit: _boxFit)],
          );
        }
      },
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
  final PageViewController pageViewController;

  const ViewVideo(this.pageViewController, this.index, this.builderIndex, {super.key});

  @override
  State<ViewVideo> createState() => _ViewVideoState();
}

class _ViewVideoState extends State<ViewVideo> {

  late final player = Player(
    configuration: PlayerConfiguration(),
  )..setVolume(0.0);
  late final controller = VideoController(player);

  final imgCtrl = Get.find<Images>();
  final client = Get.find<Client>();

  bool ready = false;

  @override
  void initState() {
    super.initState();
    final id = imgCtrl.images[widget.builderIndex].id;
    player.open(
      Media(
        // TODO this shouldn't be in UI layer and it's http only
        'http://${client.host}:${client.port}/get_files/file?file_id=$id',
        httpHeaders: {'Hydrus-Client-API-Access-Key': client.accessKey ?? ''},
      ),
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
    ever(pageCtrl.currentIndex, (i) {
      if (i != widget.builderIndex) {
        player.pause();
        player.seek(Duration.zero);
      } else {
        player.play();
      }
    });
    // Get video parameters
    var video = imgCtrl.images[widget.builderIndex];
    double width = video.width!.toDouble();
    double height = video.height!.toDouble();
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
              Image.memory(video.low!, fit: BoxFit.cover),
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