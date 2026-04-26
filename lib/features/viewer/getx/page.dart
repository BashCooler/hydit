import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:scrollview_observer/scrollview_observer.dart';


class PageGetxController extends GetxController {
  final _pinch = false.obs;
  final _pointers = RxSet<int>();

  final zoom = false.obs;
  final block = false.obs;

  bool get noScroll => _pinch.value || zoom.value || block.value;

  final PreloadPageController controller;
  final observerController = Get.find<GridObserverController>();

  final RxInt index;

  PreloadPageController get $ => controller;
  int get i => index.value;
  bool enabled(int index) => index == i;

  PageGetxController({required int initial})
      : index = initial.obs,
        controller = PreloadPageController(initialPage: initial);

  @override
  void onInit() {
    super.onInit();
    ever(_pointers, _everPointers);
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
    observerController.jumpTo(index: page - 2 > 0 ? page - 2 : 0);
  }
}