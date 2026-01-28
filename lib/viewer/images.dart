import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:hydrus_flutter/api/hydrus.dart';
import '../main.dart';
import '../search/search.dart';
import 'controllers.dart';


class HydrusImage {
  final int id;
  Uint8List? low;
  Uint8List? high;
  int? width, height;
  String? mime;
  int? duration;

  HydrusImage(this.id);
}


class Thumbnail extends StatelessWidget {
  final HydrusImage image;
  final Client client = getIt<Client>();

  final BoxFit _boxFit = BoxFit.cover;
  static const double _aspectRatio = 1.0;

  Thumbnail({super.key, required this.image});

  @override
  Widget build(BuildContext context) {

    if (image.low != null) {
      return ImageStack(
        aspectRatio: _aspectRatio,
        elements: [Image.memory(image.low!, fit: _boxFit)],
      );
    }

    final thumbnail = client.getThumbnail(image.id);
    final metadata = client.getFileMetadata([image.id], includeServicesObject: false);
    return FutureBuilder(
      future: Future.wait([thumbnail, metadata]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.hasData) {
          image.low = snapshot.data![0];
          writeMetadata(snapshot);
          return ImageStack(
            aspectRatio: _aspectRatio,
            elements: [Image.memory(snapshot.data![0], fit: _boxFit)],
          );
        }
        else {
          return const ColoredBox(color: Colors.white10);
        }
      },
    );
  }

  // MARK: METADATA

  /// Save width and height to correctly display image in [PageView].
  ///
  /// See also: [HighResImage]
  void writeMetadata(AsyncSnapshot<List<dynamic>> snapshot) {
    final metadata = snapshot.data![1][0];
    image.width = metadata['width'];
    image.height = metadata['height'];
    image.mime = metadata['mime'];
    image.duration = metadata['duration'];
  }
}


class HighResImage extends StatelessWidget {
  final HydrusImage image;
  final Client client  = getIt<Client>();

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
        elements: [
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
            elements: [
              Image.memory(image.low!, fit: _boxFit),
              Image.memory(snapshot.data!, fit: _boxFit),
            ],
          );
        }
        else {
          return ImageStack(
            aspectRatio: aspectRatio,
            elements: [Image.memory(image.low!, fit: _boxFit)],
          );
        }
      },
    );
  }
}


class ImageStack extends StatelessWidget {
  final double aspectRatio;
  final List<Widget> elements;

  const ImageStack({
    super.key,
    required this.aspectRatio,
    required this.elements,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: elements,
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

  final images = getIt<GetImages>().value;

  @override
  Widget build(BuildContext context) {
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
            enabled: builderIndex == index,
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

  const ViewVideo({super.key, required this.index, required this.builderIndex});

  @override
  State<ViewVideo> createState() => _ViewVideoState();
}

class _ViewVideoState extends State<ViewVideo> {
  late final player = Player(
    configuration: const PlayerConfiguration(
      logLevel: MPVLogLevel.debug,
    ),
  )..setVolume(0.0)..stream.log.listen((l) => log(l.toString()));
  late final controller = VideoController(player);

  final images = getIt<GetImages>().value;
  final client = getIt<Client>();

  @override
  void initState() {
    super.initState();
    player.open(
      Media(
        // r'https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4',
        'http://${client.host}:${client.port}/get_files/file?file_id=182560646',
        httpHeaders: {
          'Hydrus-Client-API-Access-Key' : client.accessKey ?? '',
        },
      ),
      play: false,
    );
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double width = images[widget.builderIndex].width!.toDouble();
    double height = images[widget.builderIndex].height!.toDouble();
    double aspectRatio = width/height;

    return SafeArea(
      child: HeroMode(
        enabled: widget.builderIndex == widget.index,
        child: Hero(
          tag: images[widget.builderIndex].id,
          createRectTween: (begin, end) {  // linear transition
            return RectTween(begin: begin, end: end);
          },
          child: ImageStack(
            aspectRatio: aspectRatio,
            elements: [
              Image.memory(images[widget.builderIndex].low!),
              Video(
                controller: controller,
                // fill: Colors.transparent,
                width: width,
                height: height,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
