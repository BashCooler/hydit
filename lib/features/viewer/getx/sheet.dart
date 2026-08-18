import 'dart:ui';

import 'package:get/get.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

// ignore: implementation_imports
import 'package:snapping_sheet_2/src/sheet_position_data.dart';


class SheetController {
  final controller = SnappingSheetController();

  final progress = 0.0.obs;

  final showServices = false.obs;

  bool get opened => progress.value > openedValue;

  static const openedValue = 0.5;

  static const closedValue = 0.0;

  static const openedFactor = SnappingPosition
      .factor(positionFactor: openedValue);

  static const closedFactor = SnappingPosition
      .factor(positionFactor: closedValue);

  void open() {
    controller.snapToPosition(openedFactor);
  }

  void close() {
    controller.snapToPosition(closedFactor);
  }

  void onSheetMoved(SheetPositionData positionData) {
    final pos = positionData.relativeToSheetHeight;

    progress.value = clampDouble(pos/openedValue, 0, 1);
  }
}
