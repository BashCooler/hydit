import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

import '../getx/page.dart';


class TagSheet extends HookWidget {
  final Widget child;

  const TagSheet({super.key, required this.child});

  static const snaps = <SnappingPosition>[
        .factor(positionFactor: 0.0),
        .factor(positionFactor: 0.5),
  ];

  void syncPageLock(dynamic positionData) {
    final PageGetxController page = Get.find();

    if (positionData.relativeToSheetHeight > 0) {
      page.block.value = true;
    } else {
      page.block.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {

    final scrollBelow = useScrollController();
    final sheet = Get.find<SnappingSheetController>();

    return SnappingSheet(
      controller: sheet,
      onSheetMoved: syncPageLock,
      lockOverflowDrag: true,
      initialSnappingPosition: .factor(positionFactor: 0.0),
      snappingPositions: snaps,
      grabbingHeight: 0,
      sheetAbove: SnappingSheetContent(
        draggable: (_) => true,
        child: child,
      ),
      sheetBelow: SnappingSheetContent(
        draggable: (_) => true,
        childScrollController: scrollBelow,
        child: Material(
          child: ListView.builder(
            itemCount: 21,
            controller: scrollBelow,
            itemBuilder: (context, index) => ListTile(title: Text('$index')),
          ),
        ),
      ),
    );
  }
}