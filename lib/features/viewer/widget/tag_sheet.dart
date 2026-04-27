import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import '../getx/page.dart';


class TagSheet extends HookWidget {
  final Widget child;

  const TagSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scrollBelow = useScrollController();
    return IgnorePointer(
      ignoring: false, // TODO переключать для активации/деактивации Dismissable
      child: SnappingSheet(
        controller: Get.find<SnappingSheetController>(),
        onSheetMoved: (positionData) {
          final page = Get.find<PageGetxController>();
          if (positionData.relativeToSheetHeight > 0) {
            page.block.value = true;
          } else {
            page.block.value = false;
          }
        },
        lockOverflowDrag: true,
        initialSnappingPosition: .factor(positionFactor: 0.0),
        snappingPositions: [
              .factor(positionFactor: 0.0),
              .factor(positionFactor: 0.5),
        ],
        grabbingHeight: 0,
        sheetAbove: SnappingSheetContent(
          draggable: true,
          child: child,
        ),
        sheetBelow: SnappingSheetContent(
          draggable: true,
          childScrollController: scrollBelow,
          child: Material(
            child: ListView.builder(
              itemCount: 21,
              controller: scrollBelow,
              itemBuilder: (context, index) => ListTile(title: Text('$index')),
            ),
          ),
        ),
      ),
    );
  }
}