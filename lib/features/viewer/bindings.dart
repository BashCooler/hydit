import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file_store.dart';

import 'getx/ui.dart';
import 'getx/gesture.dart';
import 'getx/sheet.dart';
import 'getx/video.dart';
import 'getx/page.dart';


class ViewerBindings({
  required final FileStore files,
  required final int index,
  final GridObserverController? grid,
}) extends Bindings {
  //
  final tag = 'Viewer'.unique();

  final page = PageGetxController(
    files: files,
    initial: index,
    grid: grid,
  );

  final sheet = SheetController();

  final gesture = GestureController();

  late final ui = UiController(tag: tag);

  late final video = VideoGetxController(tag: tag);

  @override
  void dependencies() {
    Get.put(page, tag: tag);
    Get.put(sheet, tag: tag);
    Get.put(gesture, tag: tag);
    Get.put(ui, tag: tag);
    Get.lazyPut(() => video, tag: tag);
  }
}
