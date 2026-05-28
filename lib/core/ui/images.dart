import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:hydit/core/data/repo.dart';
import 'package:hydit/core/domain/entities.dart';


class Thumbnail extends StatelessWidget {
  final HydrusFile image;

  const Thumbnail(this.image, {super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Get.find<Repo>();
    return AspectRatio(
      aspectRatio: 1.0,
      child: CachedNetworkImage(
        imageUrl: repo.buildUrl(image.id, thumbnail: true),
        placeholder: (context, url) => ColoredBox(color: Colors.white10),
        fit: .cover,
      ),
    );
  }
}


class HighResImage extends StatelessWidget {
  final HydrusFile image;

  const HighResImage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final Repo repo = Get.find();
    final meta = image.meta;
    final aspectRatio = meta!.width/meta.height;
    return ImageStack(
      aspectRatio: aspectRatio,
      children: [
        CachedNetworkImage(
          imageUrl: repo.buildUrl(image.id, thumbnail: true),
          placeholder: (context, url) => const SizedBox.shrink(),
          fit: .cover,
        ),
        CachedNetworkImage(
          imageUrl: repo.buildUrl(image.id),
          placeholder: (context, url) => const SizedBox.shrink(),
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