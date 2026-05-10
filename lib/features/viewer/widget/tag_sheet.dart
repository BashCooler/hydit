import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydrus_flutter/features/gallery/getx/gallery.dart';
import 'package:niku/namespace.dart' as n;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

import 'package:hydrus_flutter/core/ui/tag_list.dart';
import 'package:hydrus_flutter/core/domain/entities.dart';
import 'package:hydrus_flutter/features/editor/getx/bindings.dart';

import '../getx/page.dart';


class TagSheet extends HookWidget {
  final Widget child;
  final List<Tag> tags;
  final String tag;

  const TagSheet({
    super.key,
    required this.child,
    required this.tags,
    required this.tag,
  });

  static const snaps = <SnappingPosition>[
    SnappingPosition.factor(positionFactor: 0.0),
    SnappingPosition.factor(positionFactor: 0.5),
  ];

  void syncPageLock(dynamic positionData) {
    if (!Get.isRegistered<PageGetxController>(tag: tag)) return;
    final PageGetxController page = Get.find(tag: tag);

    if (positionData.relativeToSheetHeight > 0) {
      page.blockDismiss = true;
    } else {
      page.blockDismiss = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrollBelow = useScrollController();
    final SnappingSheetController sheet = Get.find(tag: tag);
    final PageGetxController page = Get.find(tag: tag);
    final GalleryController gallery = Get.find();

    const background = Material(child: Center());

    return SnappingSheet(
      controller: sheet,
      onSheetMoved: syncPageLock,
      lockOverflowDrag: true,
      initialSnappingPosition: snaps[0],
      snappingPositions: snaps,
      grabbingHeight: -1,
      sheetAbove: SnappingSheetContent(
        draggable: (_) => !page.zoom.value,
        child: child,
      ),
      sheetBelow: SnappingSheetContent(
        draggable: (_) => true,
        childScrollController: scrollBelow,
        child: n.Stack([
          background,
          Scaffold(
            body: TagList(
              scrollController: scrollBelow,
              tags: tags,
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => toEditorPaged(tag, page.i, gallery),
              child: const Icon(Icons.edit_note),
            ).niku
              ..padding = .only(bottom: 18),
            floatingActionButtonLocation: .miniEndFloat,
          ).niku
            ..rect
            ..safeBottom,
        ]),
      ),
    );
  }
}
