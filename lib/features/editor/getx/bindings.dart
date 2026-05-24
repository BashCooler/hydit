import 'package:get/get.dart';
import 'package:flutter/animation.dart';
import 'package:hydit/features/search/getx/search.dart';

import 'package:hydit/utils/theme.dart';
import 'package:hydit/core/domain/file_repo.dart';
import 'package:hydit/features/viewer/getx/page.dart';
import 'package:hydit/features/gallery/getx/gallery.dart';

import '../page/editor.dart';
import 'tags.dart';


Future<dynamic>? toEditorPaged(String tag, int index, FileRepo files, [GalleryController? gallery]) {
  return Get.to(() => Editor(tag: tag, mode: .paged),
    transition: .leftToRight,
    duration: AppTheme.duration,
    curve: Curves.easeInOutCubic,
    binding: EditorBindings.paged(tag, index, files, gallery),
  );
}


Future<dynamic>? toEditorBatch(String tag, FileRepo files, GalleryController gallery, List<int> ids) {
  return Get.to(() => Editor(tag: tag, mode: .batch),
    transition: .leftToRight,
    duration: AppTheme.duration,
    curve: Curves.easeInOutCubic,
    binding: EditorBindings.batch(tag, files, gallery, ids),
  );
}


class EditorBindings extends Bindings {
  final String tag;
  final Mode mode;
  final int? index;
  final List<int>? ids;
  final FileRepo files;
  final GalleryController? gallery;

  EditorBindings.paged(this.tag, this.index, this.files, [this.gallery])
      : mode = .paged,
        ids = null;

  EditorBindings.batch(this.tag, this.files, this.gallery, this.ids)
      : mode = .batch,
        index = null;

  @override
  void dependencies() {
    Get.put(FileRepo.copy(files), tag: tag);
    Get.put(TagSearchController(), tag: tag);

    switch (mode) {
      case .paged:
        final page = PageGetxController(initial: index!, grid: gallery?.grid);
        Get.put(page, tag: tag);
        Get.put(TagManager(files)..init(files[index!]));
      case .batch:
        final page = PageGetxController(initial: 0, grid: gallery?.grid);
        Get.put(page, tag: tag);
        Get.put(TagManager(files)..initBatch(ids!));
    }
  }
}