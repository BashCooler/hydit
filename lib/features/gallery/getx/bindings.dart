import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/utils/theme.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/search/getx/query.dart';

import '../page/gallery.dart';
import 'gallery.dart';
import 'selection.dart';

enum Mode { full, preview }


class GalleryPage {
  final FileStore files;

  String? tag;
  Mode mode = .full;

  GalleryPage(this.files);

  GalleryPage full() {
    mode = .full;
    return this;
  }

  GalleryPage preview() {
    mode = .preview;
    return this;
  }

  GalleryPage passTag(String tag) {
    this.tag = tag;
    return this;
  }

  void push() {
    tag = 'Gallery-${DateTime.now().microsecondsSinceEpoch}';

    Get.to(
      () => Gallery(tag: tag!, mode: mode),
      transition: .rightToLeft,
      duration: AppTheme.duration,
      curve: Curves.easeInOutCubic,
      binding: GalleryBindings(this),
    );
  }
}


class GalleryBindings extends Bindings {
  final GalleryPage page;

  GalleryBindings(this.page);

  GalleryBindings.fromTag(String tag)
      : page = GalleryPage(FileStore()).passTag(tag);

  @override
  void dependencies() {
    final fileRepo = FileStore.copy(page.files);
    final gallery = GalleryController();
    final selection = SelectionController(fileRepo, gallery);

    Get.put(gallery, tag: page.tag);
    Get.put(fileRepo, tag: page.tag);
    Get.put(selection, tag: page.tag);

    if (page.mode == .full) {
      final query = QueryController(fileRepo: fileRepo, gallery: gallery);
      Get.put(query);
    }
  }
}
