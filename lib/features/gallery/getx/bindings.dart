import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/utils/theme.dart';
import 'package:hydit/core/domain/file_repo.dart';
import 'package:hydit/features/search/getx/query.dart';

import '../page/gallery.dart';
import 'gallery.dart';
import 'selection.dart';

enum Mode { full, preview }


Future<dynamic>? toGallery({Mode mode = Mode.full, required FileRepo files}) {
  final tag = 'Gallery-${DateTime.now().microsecondsSinceEpoch}';
  return Get.to(
    () => Gallery(tag: tag, mode: mode),
    transition: .rightToLeft,
    duration: AppTheme.duration,
    curve: Curves.easeInOutCubic,
    binding: GalleryBindings(tag, files, mode),
  );
}


class GalleryBindings extends Bindings {
  final String tag;
  final Mode mode;
  final FileRepo files;

  GalleryBindings(this.tag, this.files, [this.mode = .full]);

  @override
  void dependencies() {
    final fileRepo = FileRepo.copy(files);
    final gallery = GalleryController();
    final selection = SelectionController(gallery: gallery, fileRepo: fileRepo);

    if (mode == .full) {
      final query = QueryController(fileRepo: fileRepo, gallery: gallery);
      Get.put(query);
    }

    Get
      ..put(gallery, tag: tag)
      ..put(fileRepo, tag: tag)
      ..put(selection, tag: tag);
  }
}
