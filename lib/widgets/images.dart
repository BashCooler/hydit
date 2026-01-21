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

  const Thumbnail({super.key, required this.image, required this.client});

  @override
  Widget build(BuildContext context) {

    if (image.low != null) {
      return Image.memory(image.low!, fit: _boxFit);
    }

    return FutureBuilder<Uint8List>(
      future: client.getThumbnail(image.id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          image.low = snapshot.data;
          return Image.memory(snapshot.data!, fit: _boxFit);
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

  const HighResImage({super.key, required this.image, required this.client});

  @override
  Widget build(BuildContext context) {

    if (image.high != null) {
      return Image.memory(image.high!, fit: _boxFit);
    }

    return FutureBuilder<Uint8List>(
      future: client.getFile(image.id),
      builder: (context, snapshot) {
        if (false) {
          image.low = snapshot.data;
          return InteractiveViewer(
            child: Image.memory(snapshot.data!, fit: _boxFit),
          );
        }
        else {
          return Image.memory(
            image.low!,
            fit: _boxFit,
          );
        }
      },
    );
  }
}