import 'package:full_swipe_back_gesture/full_swipe_back_gesture.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/utils/theme.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/search/getx/query.dart';
import 'package:hydit/widgets/app_pop_scope.dart';

import '../page/gallery_page.dart';
import 'gallery.dart';
import 'selection.dart';

enum Mode { full, preview }


class GalleryPage {
  final String tag;

  FileStore? files;
  bool _search = false;
  bool _editor = false;
  bool _swipe = false;
  bool _popScope = false;

  GalleryPage() : tag = 'Gallery-${DateTime.now().microsecondsSinceEpoch}';

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

  GalleryPage withAppPopScope() {
    _popScope = true;
    return this;
  }

  GalleryPage withSwipeBackGesture() {
    _swipe = true;
    return this;
  }

  Widget build() {
    Widget gallery = Gallery(tag: tag, search: _search, editor: _editor);

    if (_swipe) gallery = SwipeablePage(child: gallery);
    if (_popScope) gallery = _wrapWithPopScope(gallery);

    return gallery;
  }

  void push() {
    Get.to(
      () => build(),
      opaque: false,
      transition: .rightToLeft,
      duration: AppTheme.duration,
      curve: Curves.easeInOutCubic,
      binding: GalleryBindings(this),
    );
  }

  // MARK: WRAPPERS

  Widget _wrapWithPopScope(Widget child) {
    return AppPopScope(
      canPop: false,
      showDialog: () {
        final SelectionController selection = Get.find(tag: tag);
        final GalleryController gallery = Get.find(tag: tag);

        switch (selection.on) {
          case true:
            selection.clear();
            gallery..unlockActions()..showActions();
            return false;
          case false:
            return true;
        }
      },
      child: child,
    );
  }
}


class GalleryBindings extends Bindings {
  final GalleryPage page;

  GalleryBindings(this.page);

  @override
  void dependencies() {
    final fileRepo = page.files?.copy() ?? FileStore();
    final gallery = GalleryController();
    final selection = SelectionController(fileRepo, gallery);

    Get.put(gallery, tag: page.tag);
    Get.put(fileRepo, tag: page.tag);
    Get.put(selection, tag: page.tag);

    if (page._search) {
      final query = QueryController(fileRepo: fileRepo, gallery: gallery);
      Get.put(query);
    }
  }
}
