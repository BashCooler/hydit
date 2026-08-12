import 'package:get/get.dart';
import 'package:flutter/animation.dart';
import 'package:hydit/features/viewer/getx/sheet.dart';
import 'package:hydit/features/viewer/getx/video.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/gallery/getx/gallery.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'page/viewer.dart';
import 'getx/page.dart';


class ViewerPage {
  final String tag;

  final int index;
  final FileStore files;
  final GalleryController? gallery;

  ViewerPage(this.files, this.index, [this.gallery])
      : tag = 'Viewer'.unique();

  bool _editor = true;
  String? _heroPrefix;
  VoidCallback? _beforePush;
  VoidCallback? _onClose;

  ViewerPage editor(bool editor) {
    _editor = editor;
    return this;
  }

  ViewerPage hero({required String prefix}) {
    _heroPrefix = prefix;
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
      binding: ViewerBindings(
        tag: tag,
        files: files,
        index: index,
        grid: gallery?.grid,
      ),
      arguments: {
        "heroPrefix": _heroPrefix,
      }
    )?.then((result) {
      _onClose?.call();
    });
  }
}


class ViewerBindings implements Bindings {
  final String tag;
  final FileStore files;
  final int index;
  final GridObserverController? grid;

  const ViewerBindings({
    required this.tag,
    required this.files,
    required this.index,
    this.grid,
  });

  @override
  void dependencies() {
    Get.put(
      PageGetxController(
        files: files,
        initial: index,
        grid: grid,
      ),
      tag: tag,
    );
    Get.put(
      SheetController(),
      tag: tag,
    );
    Get.lazyPut(
      () => VideoGetxController(tag: tag),
      tag: tag,
    );
  }
}
