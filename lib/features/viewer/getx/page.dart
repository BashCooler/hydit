import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:scrollview_observer/scrollview_observer.dart';


class PageGetxController extends GetxController {
  final GridObserverController? grid;
  final PreloadPageController controller;

  final RxInt index;

  final _pinch = false.obs;
  final _pointers = RxSet<int>();

  final zoom = false.obs;

  final showServices = false.obs;

  bool get noScroll => _pinch.value || zoom.value;

  final _blockDismiss = false.obs;
  set blockDismiss(bool block) => _blockDismiss.value = block;
  bool get blockDismiss => _blockDismiss.value || zoom.value;

  final sheet = SnappingSheetController();

  final sheetProgress = 0.0.obs;

  PageGetxController({required int initial, this.grid})
    : index = initial.obs,
      controller = PreloadPageController(initialPage: initial);

  /// Current page index
  int get i => index.value;

  /// [Hero] callback. Disable the animation for preloaded pages.
  bool enabled(int index) => index == i;

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }

  void registerPointer(Object details) {
    if (details is PointerDownEvent) _pointers.add(details.pointer);
    if (details is PointerUpEvent) _pointers.remove(details.pointer);
    _pinch.value = _pointers.length > 1;
  }

  void onPageChanged(int page) {
    index.value = page;
    jumpToGridViewItem(page);
  }

  /// Navigates the visible [PageView] and keeps the background [GridView]
  /// centered on the same image.
  void navigateToPage(int page) {
    if (page == i) return;

    index.value = page;
    jumpToGridViewItem(page);

    if (!controller.hasClients) return;
    controller.jumpToPage(page);
  }

  /// Jumps to corresponding item in [GridView].
  void jumpToGridViewItem(int item) {
    switch (item) {
      case < 2:
        grid?.controller?.jumpTo(0);
      case _:
        grid?.jumpTo(index: item - 2 > 0 ? item - 2 : 0);
    }
  }

  void openSheet() {
    sheet.snapToPosition(.factor(positionFactor: 0.5));
  }

  void closeSheet() {
    sheet.snapToPosition(.factor(positionFactor: 0.0));
  }
}
