import 'package:get/get.dart';
import 'package:flutter/animation.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

import 'package:hydrus_flutter/features/gallery/getx/gallery.dart';

import '../page/viewer.dart';
import 'page.dart';


void toViewer(int index) {
  final GalleryController gallery = Get.find();

  final tag = 'Viewer-${DateTime.now().microsecondsSinceEpoch}';

  gallery..hideActions()..hideBadges();

  Get.to(() => Viewer(index, tag: tag),
    transition: .fadeIn,
    curve: Curves.easeInCubic,
    opaque: false,
    binding: ViewerBindings(index: index, tag: tag, gallery: gallery),
  );
}


class ViewerBindings implements Bindings {
  final int index;
  final String tag;
  final GalleryController gallery;

  const ViewerBindings({
    required this.index,
    required this.tag,
    required this.gallery,
  });

  @override
  void dependencies() {
    final page = PageGetxController(initial: index, grid: gallery.grid);
    Get.put(page, tag: tag);
    Get.put(SnappingSheetController(), tag: tag);
  }
}