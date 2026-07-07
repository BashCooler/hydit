import 'dart:ui';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/widgets/tag_list.dart';
import 'package:hydit/widgets/service_list.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/editor/bindings.dart';

import '../getx/page.dart';


class TagSheet extends HookWidget {
  final String tag;
  final Widget child;

  const TagSheet({
    super.key,
    required this.tag,
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
    final scroll = useScrollController();

    return SnappingSheet(
      controller: page.sheet,
      onSheetMoved: syncPageLock,
      lockOverflowDrag: true,
      initialSnappingPosition: snaps.first,
      snappingPositions: snaps,
      grabbingHeight: -1,
      sheetAbove: SnappingSheetContent(
        draggable: (_) => !page.zoom.value,
        child: child,
      ),
      sheetBelow: SnappingSheetContent(
        draggable: (_) => true,
        childScrollController: scroll,
        child: n.Stack([
          background,
          SafeArea(
            top: false,
            child: Obx(() {
              final tags = files[page.i].tags.value;

              if (page.showServices.value) {
                return ServiceList(
                  tags,
                  controller: scroll,
                  onTap: (name) => EditorPage(files, name)
                      .paged(page.i)
                      .passTag(tag)
                      .push(),
                );
              }

              return TagList(
                tags: files[page.i].all.toList(),
                scrollController: scroll,
                itemBuilder: (context, tag) {
                  return TagTile(
                    tag: tag,
                    onTap: copyTag,
                  );
                },
              );
            }),
          ),
        ]),
      ),
    );
  }
}
