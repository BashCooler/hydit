import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydrus_flutter/core/domain/file_repo.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydrus_flutter/utils/theme.dart';
import 'package:hydrus_flutter/features/search/getx/query.dart';

import '../page/gallery.dart';
import 'gallery.dart';
import 'selection.dart';

enum Mode { full, preview }


Future<dynamic>? toGallery({Mode mode = Mode.full}) {
  final tag = 'Gallery-${DateTime.now().microsecondsSinceEpoch}';
  return Get.to(
    () => Gallery(tag: tag, mode: mode),
    transition: .rightToLeft,
    duration: AppTheme.duration,
    curve: Curves.easeInOutCubic,
    binding: GalleryBindings(tag: tag, mode: mode),
  );
}


class GalleryBindings extends Bindings {
  final String tag;
  final Mode mode;

  GalleryBindings({required this.tag, this.mode = .full});

  @override
  void dependencies() {
    final fileRepo = FileRepo();
    final gallery = GalleryController();

    Get
      ..put(gallery)
      ..put(fileRepo, tag: tag)
      ..put(QueryController(fileRepo: fileRepo))
      ..put(SelectionController(gallery: gallery, fileRepo: fileRepo));
  }
}
