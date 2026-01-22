import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:hydrus_flutter/hydrus_api/hydrus.dart';


class HydrusImage {
  final int id;
  Uint8List? low;
  Uint8List? high;
  int? width, height;

  HydrusImage(this.id);
}


class Thumbnail extends StatelessWidget {
  final HydrusImage image;
  final Client client;

  final BoxFit _boxFit = BoxFit.cover;
  final double _aspectRatio = 1.0;

  const Thumbnail({super.key, required this.image, required this.client});

  @override
  Widget build(BuildContext context) {

    if (image.low != null) {
      return ImageStack(
        aspectRatio: _aspectRatio,
        elements: [Image.memory(image.low!, fit: _boxFit)],
      );
    }

    return FutureBuilder<Uint8List>(
      future: client.getThumbnail(image.id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          image.low = snapshot.data;
          return ImageStack(
            aspectRatio: _aspectRatio,
            elements: [Image.memory(snapshot.data!, fit: _boxFit)],
          );
        }
        else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}


class HighResImage extends StatelessWidget {
  final HydrusImage image;
  final Client client;

  final BoxFit _boxFit = BoxFit.cover;
  final double _aspectRatio = 16/10;

  const HighResImage({super.key, required this.image, required this.client});

  @override
  Widget build(BuildContext context) {

    if (image.high != null) {
      return ImageStack(
        aspectRatio: _aspectRatio,
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
            aspectRatio: _aspectRatio,
            elements: [
              Image.memory(image.low!, fit: _boxFit),
              Image.memory(snapshot.data!, fit: _boxFit),
            ],
          );
        }
        else {
          return ImageStack(
            aspectRatio: _aspectRatio,
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
