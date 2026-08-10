import 'package:get/get.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';


class SheetController {
  final controller = SnappingSheetController();

  final progress = 0.0.obs;

  static const opened = SnappingPosition.factor(positionFactor: 0.5);

  static const closed = SnappingPosition.factor(positionFactor: 0.0);

  void open() {
    controller.snapToPosition(opened);
  }

  void close() {
    controller.snapToPosition(closed);
  }
}
