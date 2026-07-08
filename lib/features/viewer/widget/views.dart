import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/features/viewer/widget/image_view.dart';
import 'package:hydit/features/viewer/widget/video_view.dart';

import 'package:hydit/reactive/file.dart';
import 'package:hydit/widgets/images.dart';

import '../getx/page.dart';


class ViewFile extends StatelessWidget {
  final int index;
  final HydrusFile file;
  final String tag;
  final Object? heroTag;

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
        return ImageView(
          key: ValueKey(file.id),
          width: file.meta.width,
          height: file.meta.height,
          onZoomChanged: (zoom) => page.zoom.value = zoom,
          child: ObxHero(
            index: index,
            tag: heroTag ?? file.id,
            page: page,
            child: HighResImage(image: file),
          ),
        );
      case 'video':
        return VideoView(index: index, file: file, tag: tag);
      case _:
        return NotSupported(file.meta.type);
    }
  }
}


class ObxHero extends StatelessWidget {

  /// The identifier for this particular hero.
  final Object tag;

  final int index;
  final PageGetxController page;
  final Widget child;

  const ObxHero({
    super.key,
    required this.tag,
    required this.index,
    required this.page,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => HeroMode(
      enabled: page.enabled(index),
      child: LinearHero(tag: tag, child: child),
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
