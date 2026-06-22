import 'dart:ui';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:niku/namespace.dart' as n;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

import 'package:hydit/widgets/tag_list.dart';

import '../getx/page.dart';


class TagSheet extends HookWidget {
  final String tag;
  final void Function()? onFloatingActionButtonTap;
  final Widget child;

  const TagSheet({
    super.key,
    required this.tag,
    this.onFloatingActionButtonTap,
    required this.child,
  });

  FileStore get files => Get.find(tag: tag);
  PageGetxController get page => Get.find(tag: tag);

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
            body: Obx(() {
              final tags = files[page.i].meta?.all;
              switch (tags) {
                case null:
                  return MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: Skeletonizer(
                      child: ListView.builder(
                        itemCount: 6,
                        controller: scrollBelow,
                        itemBuilder: (context, index) {
                          return ListTile(title: Text('X' * 16));
                        },
                      ),
                    ),
                  );
                case _:
                  return TagList(
                    tags: tags.toList(),
                    scrollController: scrollBelow,
                    itemBuilder: (context, tag) => TagTile(tag: tag),
                  );
              }
            }),
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
