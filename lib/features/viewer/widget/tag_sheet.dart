import 'dart:ui';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

import 'package:hydit/widgets/tag_list.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/features/gallery/getx/gallery.dart';

import '../getx/page.dart';


class TagSheet extends HookWidget {
  final Widget child;
  final List<Tag> tags;
  final String tag;
  final GalleryController? gallery;
  final void Function()? onFloatingActionButtonTap;

  const TagSheet({
    super.key,
    required this.child,
    required this.tags,
    required this.tag,
    required this.gallery,
    this.onFloatingActionButtonTap,
  });

  static const snaps = <SnappingPosition>[
    SnappingPosition.factor(positionFactor: 0.0),
    SnappingPosition.factor(positionFactor: 0.5),
  ];

  static const background = Material(child: Center());

  void syncPageLock(dynamic positionData) {
    if (!Get.isRegistered<PageGetxController>(tag: tag)) return;
    final PageGetxController page = Get.find(tag: tag);

    final pos = positionData.relativeToSheetHeight;
    page.sheetProgress.value = clampDouble(pos/0.5, 0, 1);
    if (pos > 0) {
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
            floatingActionButton: buildFloatingActionButton(),
            floatingActionButtonLocation: .miniEndFloat,
          ).niku
            ..rect
            ..safeBottom,
        ]),
      ),
    );
  }

  Widget? buildFloatingActionButton() {
    if (onFloatingActionButtonTap == null) return null;
    return Padding(
      padding: const .only(bottom: 18),
      child: FloatingActionButton(
        onPressed: onFloatingActionButtonTap,
        child: const Icon(Icons.edit_note),
      ),
    );
  }
}
