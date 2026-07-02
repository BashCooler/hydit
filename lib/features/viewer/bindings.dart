import 'package:get/get.dart';
import 'package:flutter/animation.dart';
import 'package:hydit/features/viewer/getx/video.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/gallery/getx/gallery.dart';

import 'page/viewer.dart';
import 'getx/page.dart';


class ViewerPage {
  final int index;
  final FileStore files;
  final GalleryController gallery;

  String? tag;
  bool _editor = true;
  VoidCallback? _beforePush;
  VoidCallback? _onClose;

  ViewerPage(this.files, this.index, this.gallery);

  ViewerPage editor(bool editor) {
    _editor = editor;
    return this;
  }

  ViewerPage beforePush(VoidCallback callback) {
    _beforePush = callback;
    return this;
  }

  ViewerPage onClose(VoidCallback callback) {
    _onClose = callback;
    return this;
  }

  void push() {
    tag ??= 'Viewer-${DateTime.now().microsecondsSinceEpoch}';

    _beforePush?.call();

    Get.to(
      () => Viewer(
        tag: tag!,
        index: index,
        gallery: gallery,
        editor: _editor,
      ),
      transition: .fadeIn,
      curve: Curves.easeInCubic,
      opaque: false,
      binding: ViewerBindings(this),
    )?.then((result) {
      _onClose?.call();
    });
  }
}


class ViewerBindings implements Bindings {
  final ViewerPage page;

  const ViewerBindings(this.page);

  @override
  void dependencies() {
    Get.put(
      FileStore.copy(page.files),
      tag: page.tag,
    );
    Get.put(
      PageGetxController(initial: page.index, grid: page.gallery.grid),
      tag: page.tag,
    );
    Get.put(
      SnappingSheetController(),
      tag: page.tag,
    );
    Get.put(
      VideoGetxController(tag: page.tag!),
      tag: page.tag,
    );
  }
}