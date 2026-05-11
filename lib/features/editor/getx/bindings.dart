import 'package:get/get.dart';
import 'package:flutter/animation.dart';

import 'package:hydrus_flutter/utils/theme.dart';
import 'package:hydrus_flutter/core/domain/file_repo.dart';
import 'package:hydrus_flutter/features/viewer/getx/page.dart';
import 'package:hydrus_flutter/features/search/getx/query.dart';
import 'package:hydrus_flutter/features/gallery/getx/gallery.dart';
import 'package:hydrus_flutter/features/gallery/getx/selection.dart';

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


Future<dynamic>? toEditorBatch(String tag, FileRepo files, GalleryController gallery) {
  return Get.to(() => Editor(tag: tag, mode: .batch),
    transition: .leftToRight,
    duration: AppTheme.duration,
    curve: Curves.easeInOutCubic,
    binding: EditorBindings.batch(tag, files, gallery),
  );
}


class EditorBindings extends Bindings {
  final String tag;
  final Mode mode;
  final int? index;
  final FileRepo files;
  final GalleryController? gallery;

  EditorBindings.paged(this.tag, this.index, this.files, [this.gallery])
      : mode = .paged;

  EditorBindings.batch(this.tag, this.files, this.gallery)
      : mode = .batch,
        index = null;

  @override
  void dependencies() {
    Get.put(QueryController(gallery: gallery), tag: tag);
    Get.put(FileRepo.copy(files), tag: tag);

    switch (mode) {
      case .paged:
        final page = PageGetxController(initial: index!, grid: gallery?.grid);
        Get.put(page, tag: tag);
        Get.put(TagManager(files)..init(files[index!]));
      case .batch:
        final SelectionController selection = Get.find();
        Get.put(TagManager(files)..initBatch(selection.ids.toList()));
    }
  }
}