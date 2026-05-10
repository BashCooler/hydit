import 'package:get/get.dart';
import 'package:flutter/animation.dart';
import 'package:hydrus_flutter/features/gallery/getx/selection.dart';

import 'package:hydrus_flutter/utils/theme.dart';
import 'package:hydrus_flutter/core/domain/file_repo.dart';
import 'package:hydrus_flutter/features/viewer/getx/page.dart';
import 'package:hydrus_flutter/features/search/getx/query.dart';

import '../page/editor.dart';
import 'tags.dart';


void toEditor(String tag, Mode mode) {
  Get.to(() => Editor(tag: tag, mode: mode),
    transition: .leftToRight,
    duration: AppTheme.duration,
    curve: Curves.easeInOutCubic,
    binding: EditorBindings(tag: tag, mode: mode),
  );
}


class EditorBindings extends Bindings {
  final String tag;
  final Mode mode;

  EditorBindings({required this.tag, required this.mode});

  @override
  void dependencies() {
    Get.put(QueryController(), tag: tag);

    final index = switch (mode) {
      .paged => Get.find<PageGetxController>(tag: tag).i,
      .batch => 0,
    };

    switch (mode) {
      case .paged:
        final FileRepo files = Get.find();
        Get.put(TagManager()..init(files[index].service));
      case .batch:
        final SelectionController selection = Get.find();
        Get.put(TagManager()..initBatch(selection.ids.toList()));
    }
  }
}