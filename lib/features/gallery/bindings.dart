import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:full_swipe_back_gesture/full_swipe_back_gesture.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/search/getx/query.dart';

import 'getx/gallery.dart';
import 'getx/selection.dart';
import 'page/gallery_page.dart';


class GalleryPage {
  final String tag;
  final GlobalKey<InnerDrawerState>? state;

  FileStore? files;
  bool _search = false;
  bool _editor = false;
  bool _swipe = false;

  GalleryPage({this.state})
      : tag = 'Gallery'.unique();

  GalleryPage withSearch() {
    _search = true;
    return this;
  }

  GalleryPage withEditor() {
    _editor = true;
    return this;
  }

  GalleryPage withFiles(FileStore files) {
    this.files = files;
    return this;
  }

  GalleryPage predictive() {
    _swipe = true;
    return this;
  }

  Widget build() {
    Widget gallery = Gallery(
      tag: tag,
      state: state,
      search: _search,
      editor: _editor,
    );

    if (_swipe) gallery = SwipeablePage(child: gallery);

    return gallery;
  }

  void push() {
    Get.to(
      () => build(),
      opaque: false,
      transition: .rightToLeft,
      duration: transition,
      curve: Curves.easeInOutCubic,
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
    final gallery = GalleryController();
    final selection = SelectionController(tag: page.tag);

    Get.put(gallery, tag: page.tag);
    Get.put(selection, tag: page.tag);

    if (page._search) {
      Get.put(
        FileStore.search(),
        tag: page.tag,
      );
      Get.put(
        QueryController(tag: page.tag),
        tag: page.tag,
      );
    } else {
      Get.put(
        page.files?.copy() ?? FileStore(),
        tag: page.tag,
      );
    }
  }
}
