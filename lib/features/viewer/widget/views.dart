import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/features/viewer/widget/image_view.dart';

import 'package:hydit/reactive/file.dart';
import 'package:hydit/widgets/images.dart';

import '../getx/page.dart';
import 'video_view.dart';


class ViewFile extends StatelessWidget {
  final int index;
  final HydrusFile file;
  final String tag;
  final String? heroTag;

  const ViewFile({
    super.key,
    required this.index,
    required this.tag,
    required this.file,
    this.heroTag,
  });

  PageGetxController get page => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    switch(file.meta.type) {
      case 'image':
        return ZoomableImageView(
          key: ValueKey(file.id),
          tag: tag,
          index: index,
          image: file,
          heroTag: heroTag,
          page: page,
        );
      case 'video':
        return VideoView(
          index: index,
          file: file,
          tag: tag,
          heroTag: heroTag,
        );
      case _:
        return NotSupported(file.meta.type);
    }
  }
}


class ObxHero extends StatelessWidget {
  final int index;
  final Object heroTag;
  final String getTag;
  final Widget child;

  const ObxHero({
    super.key,
    required this.index,
    required this.heroTag,
    required this.getTag,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final PageGetxController controller = Get.find(tag: getTag);
    return Obx(() => HeroMode(
      enabled: controller.enabled(index),
      child: LinearHero(tag: heroTag, child: child),
    ));
  }
}


class NotSupported extends StatelessWidget {
  final String? type;

  const NotSupported(this.type, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: .center,
      spacing: 15,
      children: [
        Icon(Icons.image_not_supported_outlined, size: 96),
        Text('Media type "$type" is unsupported'),
      ],
    );
  }
}
