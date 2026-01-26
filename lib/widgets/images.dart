import 'dart:developer';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:hydrus_flutter/api/hydrus.dart';
import '../main.dart';


class HydrusImage {
  final int id;
  Uint8List? low;
  Uint8List? high;
  int? width, height;

  HydrusImage(this.id);
}


class Thumbnail extends StatelessWidget {
  final HydrusImage image;
  final Client client = getIt<GetClient>().client;

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

  /// Save width and height to correctly display image in [PageView].
  ///
  /// See also: [HighResImage]
  void writeMetadata(AsyncSnapshot<List<dynamic>> snapshot) {
    image.width = snapshot.data![1][0]['width'];
    image.height = snapshot.data![1][0]['height'];
  }
}


class HighResImage extends StatelessWidget {
  final HydrusImage image;
  final Client client  = getIt<GetClient>().client;

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
