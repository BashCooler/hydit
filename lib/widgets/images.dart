import 'package:flutter/material.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';

import 'package:hydit/reactive/file.dart';


class Thumbnail extends StatelessWidget {
  final HydrusFile image;

  const Thumbnail(this.image, {super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: CachedNetworkImage(
        imageUrl: image.thumbnailUrl,
        placeholder: (context, url) {
          return const ColoredBox(color: Colors.white10);
        },
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
    return ImageStack(
      aspectRatio: image.meta.aspectRatio,
      children: [
        CachedNetworkImage(
          imageUrl: image.thumbnailUrl,
          placeholder: (context, url) => const SizedBox.shrink(),
          fit: .cover,
        ),
        CachedNetworkImage(
          imageUrl: image.url,
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


class LinearHero extends StatelessWidget {
  final Object tag;
  final Widget child;

  const LinearHero({super.key, required this.tag, required this.child});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      createRectTween: (b, e) => RectTween(begin: b, end: e),
      child: child,
    );
  }
}
