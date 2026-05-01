import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

import 'package:hydrus_flutter/core/domain/entities.dart';
import 'package:hydrus_flutter/core/ui/tag_list.dart';

import '../getx/page.dart';


class TagSheet extends HookWidget {
  final Widget child;
  final List<Tag> tags;

  const TagSheet({super.key, required this.child, required this.tags});

  static const snaps = <SnappingPosition>[
        .factor(positionFactor: 0.0),
        .factor(positionFactor: 0.5),
  ];

  void syncPageLock(dynamic positionData) {
    final PageGetxController page = Get.find();

    if (positionData.relativeToSheetHeight > 0) {
      page.blockDismiss.value = true;
    } else {
      page.blockDismiss.value = false;
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
      grabbingHeight: -1,
      sheetAbove: SnappingSheetContent(
        draggable: (_) => true,
        child: child,
      ),
      sheetBelow: SnappingSheetContent(
        draggable: (_) => true,
        childScrollController: scrollBelow,
        child: Material(
          child: TagList(
            scrollController: scrollBelow,
            trailing: const SizedBox.shrink(),
            tags: tags,
          ),
        ),
      ),
    );
  }
}