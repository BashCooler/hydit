import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';

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

