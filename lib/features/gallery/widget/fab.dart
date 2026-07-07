import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/features/gallery/getx/gallery.dart';

import 'package:hydit/widgets/switcher.dart';
import 'package:hydit/widgets/acrylic.dart' as a;
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/search/bindings.dart';

import '../getx/selection.dart';

typedef FAB = FloatingActionButton;


class GalleryFAB extends StatelessWidget {
  final String tag;

  const GalleryFAB({super.key, required this.tag});

  FileStore get files => Get.find(tag: tag);
  GalleryController get gallery => Get.find(tag: tag);
  SelectionController get selection => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SequencedSwitcher(
        visible: selection.off && gallery.badges,
        showFirst: !files.loader!.failed,
        first: a.FAB(
          icon: const Icon(Icons.search),
          onTap: SearchPage(tag: tag).push,
        ),
        second: FAB(
          onPressed: files.loader!.retry,
          child: const Icon(Icons.refresh),
        ),
      );
    });
  }
}
