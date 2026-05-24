import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:scrollview_observer/scrollview_observer.dart';


class PageGetxController extends GetxController {
  final RxInt index;
  final _pinch = false.obs;
  final _pointers = RxSet<int>();
  late final Worker _pointersWorker;

  final zoom = false.obs;
  final _blockDismiss = false.obs;

  final GridObserverController? grid;
  final PreloadPageController controller;

  final sheetProgress = 0.0.obs;

  PageGetxController({required int initial, this.grid})
    : index = initial.obs,
      controller = PreloadPageController(initialPage: initial);

  bool get noScroll => _pinch.value || zoom.value;
  bool get blockDismiss => _blockDismiss.value || zoom.value;
  set blockDismiss(bool block) => _blockDismiss.value = block;

  PreloadPageController get $ => controller;
  int get i => index.value;

  bool enabled(int index) => index == i;

  @override
  void onInit() {
    super.onInit();
    _pointersWorker = ever(_pointers, _everPointers);
  }

  @override
  void onClose() {
    _pointersWorker.dispose();
    controller.dispose();
    super.onClose();
  }

  void _everPointers(Set<int> callback) {
    _pinch.value = _pointers.length > 1;
  }

  void registerPointer(Object details) {
    if (details is PointerDownEvent) _pointers.add(details.pointer);
    if (details is PointerUpEvent) _pointers.remove(details.pointer);
  }

  void onPageChanged(int page) {
    index.value = page;
    jumpToPageInBackground(page);
  }

  /// Navigates the visible [PageView] and keeps the background [GridView]
  /// centered on the same image.
  void navigateToPage(int page) {
    if (page == i) return;

    index.value = page;
    jumpToPageInBackground(page);

    if (!controller.hasClients) return;
    controller.jumpToPage(page);
  }

  /// Jumps to corresponding item in [GridView].
  ///
  /// Example: you open item `0` in the [GridView], then scroll to file `40`
  /// using [PageView]. [jumpToPageInBackground] scrolls to picture `40` in
  /// the background to lazy load new thumbnails and so when you close
  /// [PageView] you end up seeing item `40`, not `0`.
  ///
  /// TODO `-2` in `page - 2` is a tech debt!
  /// If [SliverGridDelegateWithFixedCrossAxisCount.crossAxisCount] changed
  /// in settings the `-2` offset becomes irrelevant
  void jumpToPageInBackground(int page) {
    switch (page) {
      case < 2:
        grid?.controller?.jumpTo(0);
      case _:
        grid?.jumpTo(index: page - 2 > 0 ? page - 2 : 0);
    }
  }
}
