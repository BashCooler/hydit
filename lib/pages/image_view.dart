import 'package:flutter/material.dart';
import 'package:hydrus_flutter/hydrus_api/hydrus.dart';
import 'package:hydrus_flutter/widgets/images.dart';


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
      appBar: AppBar(),
      body: Center(
        child: _Hero(
          images: widget.images,
          index: widget.index,
          client: widget.client,
        ),
      ),
    );
  }
}


class _Hero extends StatelessWidget {
  final List<HydrusImage> images;
  final int index;
  final Client client;

  const _Hero({required this.images, required this.index, required this.client});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: images[index].id,
      child: AspectRatio(
        aspectRatio: 16/10,
        child: HighResImage(image: images[index], client: client),
      ),
    );
  }
}