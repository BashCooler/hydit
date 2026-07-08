import 'package:get/get.dart';
import 'package:flutter/animation.dart';
import 'package:hydit/features/viewer/getx/video.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/gallery/getx/gallery.dart';

import 'page/viewer.dart';
import 'getx/page.dart';


class ViewerPage {
  final String tag;

  final int index;
  final FileStore files;
  final GalleryController gallery;

  ViewerPage(this.files, this.index, this.gallery)
      : tag = 'Viewer'.unique();

  bool _editor = true;
  VoidCallback? _beforePush;
  VoidCallback? _onClose;

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
    _beforePush?.call();

    Get.to(
      () => Viewer(
        tag: tag,
        index: index,
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
      PageGetxController(
        files: page.files,
        initial: page.index,
        grid: page.gallery.grid,
      ),
      tag: page.tag,
    );
    Get.put(
      VideoGetxController(tag: page.tag),
      tag: page.tag,
    );
  }
}
