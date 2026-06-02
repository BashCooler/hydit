import 'package:get/get.dart';
import 'package:flutter/animation.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

import 'package:hydit/utils/theme.dart';
import 'package:hydit/reactive/files.dart';
import 'package:hydit/features/gallery/getx/gallery.dart';

import '../page/viewer.dart';
import 'page.dart';


Future<void> toViewer({
  required int index,
  required FileStore files,
  GalleryController? gallery,
  bool showFloatingActionButton = true,
}) async {
  final tag = 'Viewer-${DateTime.now().microsecondsSinceEpoch}';

  gallery?..hideActions()..hideBadges();

  await Get.to(
    () => Viewer(
      index: index,
      tag: tag,
      gallery: gallery,
      showFloatingActionButton: showFloatingActionButton,
    ),
    transition: .fadeIn,
    curve: Curves.easeInCubic,
    opaque: false,
    binding: ViewerBindings(
      index: index,
      tag: tag,
      files: files,
      gallery: gallery,
    ),
  );

  Future.delayed(AppTheme.duration, () {
    gallery?..showActions()..showBadges();
  });
}


class ViewerBindings implements Bindings {
  final int index;
  final String tag;
  final GalleryController? gallery;
  final FileStore files;

  const ViewerBindings({
    required this.index,
    required this.tag,
    required this.gallery,
    required this.files,
  });

  @override
  void dependencies() {
    final page = PageGetxController(initial: index, grid: gallery?.grid);
    final sheet = SnappingSheetController();
    final fileRepo = FileStore.copy(files);

    Get
      ..put(fileRepo, tag: tag)
      ..put(page, tag: tag)
      ..put(sheet, tag: tag);
  }
}