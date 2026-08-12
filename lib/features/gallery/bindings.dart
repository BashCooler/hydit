import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/services/loader.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/search/getx/query.dart';

import 'getx/gallery.dart';
import 'getx/selection.dart';
import 'page/gallery_page.dart';


class GalleryPage {
  final String tag;

  Iterable<int>? ids;
  bool _search = false;
  bool _editor = false;
  bool _swipe = false;
  Widget? _trailing;

  GalleryPage() : tag = 'Gallery'.unique();

  GalleryPage withSearch() {
    _search = true;
    return this;
  }

  GalleryPage withEditor() {
    _editor = true;
    return this;
  }

  GalleryPage withFiles(Iterable<int> ids) {
    this.ids = ids;
    return this;
  }

  GalleryPage predictive() {
    _swipe = true;
    return this;
  }

  GalleryPage trailing(Widget trailing) {
    _trailing = trailing;
    return this;
  }

  Widget build() => Gallery(
    tag: tag,
    trailing: _trailing,
    editor: _editor,
    swipeGesture: _swipe,
  );

  void push() {
    Get.to(
      () => build(),
      curve: Curves.easeInOutCubic,
      opaque: false,
      binding: GalleryBindings(this),
    );
  }

  /// Callback to pass to [AppShell].
  ///
  /// Returns:
  /// - true - show dialog
  /// - false - don't show dialog
  bool dialog() {
    final SelectionController selection = Get.find(tag: tag);

    switch (selection.on) {
      case true:
        selection.clear();
        return false;
      case false:
        return true;
    }
  }
}


class GalleryBindings extends Bindings {
  final GalleryPage page;

  GalleryBindings(this.page);

  @override
  void dependencies() {
    Get.put(
      GalleryController(),
      tag: page.tag,
    );

    Get.lazyPut(
      () => SelectionController(tag: page.tag),
      tag: page.tag,
    );

    Get.put(
      FileStore(page.ids ?? .empty()),
      tag: page.tag,
    );

    if (page._search) {
      Get.put(
        Loader(tag: page.tag),
        tag: page.tag,
      );

      Get.put(
        QueryController(tag: page.tag),
        tag: page.tag,
      );
    }
  }
}
