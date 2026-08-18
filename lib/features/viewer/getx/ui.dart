import 'package:get/get.dart';
import 'package:hydit/features/viewer/getx/gesture.dart';
import 'package:hydit/features/viewer/getx/sheet.dart';


class UiController extends GetxController {
  final String tag;

  UiController({required this.tag});

  final visible = true.obs;

  GestureController get gesture => Get.find(tag: tag);

  SheetController get sheet => Get.find(tag: tag);

  late final Worker zoomWorker;

  @override
  void onInit() {
    super.onInit();
    zoomWorker = ever(gesture.zoom, onZoomChanged);
  }

  @override
  void onClose() {
    zoomWorker();
    super.onClose();
  }

  void onZoomChanged(bool value) {
    if (value && sheet.closed) visible.value = false;
  }

  void toggle() {
    if (sheet.closed) visible.toggle();
  }
}

