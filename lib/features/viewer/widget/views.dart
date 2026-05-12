import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';

import 'package:hydrus_flutter/core/ui/common.dart';
import 'package:hydrus_flutter/core/domain/entities.dart';

import '../getx/page.dart';
import 'image_view.dart';
import 'video_view.dart';


class ViewFile extends StatelessWidget {
  final int index;
  final HydrusFile file;
  final String tag;

  const ViewFile({
    super.key,
    required this.index,
    required this.tag,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    if (file.type != null) {
      return buildContent(file.type!);
    }
    return FutureBuilder(
      future: file.checkForMetadata(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == .done) {
          return buildContent(file.type!);
        } else {
          return const Center(
            child: ExpressiveLoadingIndicator(),
          );
        }
      },
    );
  }

  Widget buildContent(String type) {
    switch (type) {
      case 'image':
        return ViewImageX(index: index, file: file, tag: tag);
      case 'video':
        return ViewVideo(index: index, file: file, tag: tag);
      case _:
        return NotSupported(file.type);
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
