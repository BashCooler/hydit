import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/services/loader.dart';
import 'package:hydit/widgets/switcher.dart';
import 'package:hydit/widgets/acrylic.dart' as a;
import 'package:hydit/features/search/bindings.dart';

import '../getx/gallery.dart';
import '../getx/selection.dart';

typedef FAB = FloatingActionButton;


class GalleryFAB extends StatelessWidget {
  final String tag;

  const GalleryFAB({super.key, required this.tag});

  GalleryController get gallery => Get.find(tag: tag);
  SelectionController get selection => Get.find(tag: tag);

  Loader? get loader => maybeFind(tag: tag);

  @override
  Widget build(BuildContext context) {
    final loader = this.loader;

    if (loader == null) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      return SequencedSwitcher(
        visible: selection.off && gallery.badges,
        showFirst: !loader.failed,
        first: a.FAB(
          icon: const Icon(Icons.search),
          onTap: SearchPage(tag: tag).push,
        ),
        second: FAB(
          onPressed: loader.retry,
          child: const Icon(Icons.refresh),
        ),
      );
    });
  }
}
