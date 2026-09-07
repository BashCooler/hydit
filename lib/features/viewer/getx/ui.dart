import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hydit/features/viewer/getx/gesture.dart';
import 'package:hydit/features/viewer/getx/sheet.dart';


class UiController extends GetxController {
  final String tag;

  UiController({required this.tag});

  final visible = true.obs;

  GestureController get gesture => Get.find(tag: tag);

  SheetController get sheet => Get.find(tag: tag);

  bool get hidden => !visible.value;

  late final Worker zoomWorker;

  late final Worker chromeWorker;

  @override
  void onInit() {
    super.onInit();
    zoomWorker = ever(gesture.zoom, onZoomChanged);
    chromeWorker = ever(visible, updateSystemUiMode);
  }

  @override
  void onClose() {
    zoomWorker();
    chromeWorker();
    super.onClose();
  }

  void onZoomChanged(bool value) {
    if (value && sheet.closed) visible.value = false;
  }

  void toggle() {
    if (sheet.closed) visible.toggle();
  }

  void updateSystemUiMode(bool visible) => visible
      ? SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)
      : SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

