import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hydrus_flutter/hydrus_api/hydrus.dart';
import 'package:hydrus_flutter/main.dart';

class ImageView extends StatefulWidget {
  final int index;
  final Client client;
  final List<HydrusImage> images;

  const ImageView({
    super.key,
    required this.images,
    required this.index,
    required this.client,
  });

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(),
      body: Center(
        child: Hero(
          tag: widget.images[widget.index].id,
          child: SizedBox.expand(
            child: HighResImage(
              image: widget.images[widget.index],
              client: widget.client,
            ),
          ),
        ),
      ),
    );
  }
}

class HighResImage extends StatelessWidget {
  final HydrusImage image;
  final Client client;

  final BoxFit _boxFit = BoxFit.contain;

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