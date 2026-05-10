import 'package:get/get.dart';
import 'package:flutter/animation.dart';
import 'package:hydrus_flutter/features/gallery/getx/selection.dart';
import 'package:hydrus_flutter/features/viewer/getx/page.dart';

import 'package:hydrus_flutter/utils/theme.dart';
import 'package:hydrus_flutter/core/domain/file_repo.dart';
import 'package:hydrus_flutter/features/search/getx/query.dart';

import '../page/editor.dart';
import 'tags.dart';


Future<dynamic>? toEditor(String tag, Mode mode, int index) {
  return Get.to(() => Editor(tag: tag, mode: mode),
    transition: .leftToRight,
    duration: AppTheme.duration,
    curve: Curves.easeInOutCubic,
    binding: EditorBindings(tag, mode, index),
  );
}


class EditorBindings extends Bindings {
  final String tag;
  final Mode mode;
  final int index;

  EditorBindings(this.tag, this.mode, this.index);

  @override
  void dependencies() {
    Get.put(QueryController(), tag: tag);

    switch (mode) {
      case .paged:
        try {
          Get.find<PageGetxController>();
        } catch (e) {
          // This controller doesn't belong to any PageView, it
          // serves only to connect Editor with GridView
          Get.put(PageGetxController(initial: index), tag: tag);
        }
        final FileRepo files = Get.find();
        Get.put(TagManager()..init(files[index]));
      case .batch:
        final SelectionController selection = Get.find();
        Get.put(TagManager()..initBatch(selection.ids.toList()));
    }
  }
}