import 'package:get/get.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

import 'page.dart';


class ViewerBindings implements Bindings {
  final int index;
  final String tag;

  const ViewerBindings({
    required this.index,
    required this.tag,
  });

  @override
  void dependencies() {
    Get.put(PageGetxController(initial: index), tag: tag);
    Get.put(SnappingSheetController(), tag: tag);
  }
}