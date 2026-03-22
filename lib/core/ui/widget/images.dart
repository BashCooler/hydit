import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:hydrus_flutter/core/data/hydrus.dart';
import 'package:hydrus_flutter/core/logic/entities.dart';


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