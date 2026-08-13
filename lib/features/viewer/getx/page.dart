import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/entities/cache.dart';
import 'package:hydit/services/services.dart';
import 'package:hydit/widgets/common/dialog.dart';


class PageGetxController extends GetxController {
  final GridObserverController? grid;
  final PreloadPageController controller;
  final FileStore files;

  final RxInt index;

  PageGetxController({required this.files, required int initial, this.grid})
      : index = initial.obs,
        controller = PreloadPageController(initialPage: initial);

  final _pinch = false.obs;
  final _pointers = RxSet<int>();

  final zoom = false.obs;

  final showServices = false.obs;

  bool get noScroll => _pinch.value || zoom.value;

  final _blockDismiss = false.obs;
  set blockDismiss(bool block) => _blockDismiss.value = block;
  bool get blockDismiss => _blockDismiss.value || zoom.value;

  /// Current page index.
  int get i => index.value;

  /// Currently selected file.
  HydrusFile get current => files[i];

  Repo get repo => Get.find();

  FileCache get cache => Get.find();

  HydrusFile jumpNext() {
    jumpToPage(i + 1);
    return current;
  }

  HydrusFile jumpPrevious() {
    jumpToPage(i - 1);
    return current;
  }

  Future<void> nextPage() => controller.nextPage(
    duration: 150.ms,
    curve: Curves.decelerate,
  );

  Future<void> previousPage() => controller.previousPage(
    duration: 150.ms,
    curve: Curves.decelerate,
  );

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
  void jumpToPage(int page) {
    if (page == i || page < 0 || page >= files.length) return;

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

  Future<void> delete() async {
    final ids = [current.id];

    Future<Result<void>> onApply() async {
      if (i == files.length - 1 && files.length > 1) {
        await previousPage();
      }

      return repo.api
          .deleteFiles(ids)
          .run()
          .tapFailure(Snack.error);
    }

    final token = CompletionToken();

    await LoadingDialog.show(
      icon: const Icon(Icons.delete_forever),
      title: const Text('Delete file?'),
      loadingTitle: const Text('Deleting...'),
      onApply: onApply,
      token: token,
    );

    if (token.completed) {
      cache.remove(ids, getOffAll: files.length < 2);
    }
  }
}
