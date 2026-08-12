import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydit/reactive/file_store.dart';

import 'getx/sheet.dart';
import 'getx/video.dart';
import 'getx/page.dart';


class ViewerBindings implements Bindings {
  final String tag;
  final FileStore files;
  final int index;
  final GridObserverController? grid;

  const ViewerBindings({
    required this.tag,
    required this.files,
    required this.index,
    this.grid,
  });

  @override
  void dependencies() {
    Get.put(
      PageGetxController(
        files: files,
        initial: index,
        grid: grid,
      ),
      tag: tag,
    );
    Get.put(
      SheetController(),
      tag: tag,
    );
    Get.lazyPut(
      () => VideoGetxController(tag: tag),
      tag: tag,
    );
  }
}
