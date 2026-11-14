import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

import 'package:hydit/utils/get.dart';
import 'package:hydit/widgets/tag.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/features/editor/bindings.dart';
import 'package:hydit/features/editor/page/editor.dart';

import '../getx/page.dart';
import '../getx/video.dart';
import '../getx/sheet.dart';
import '../getx/gesture.dart';


class TagSheet extends HookWidget {
  final String tag;
  final Widget child;

  const TagSheet({
    super.key,
    required this.tag,
    required this.child,
  });

  PageGetxController get page => Get.find(tag: tag);

  SheetController get sheet => Get.find(tag: tag);

  GestureController get gesture => Get.find(tag: tag);

  VideoGetxController get video => Get.find(tag: tag);

  static const snaps = [
    SheetController.closedFactor,
    SheetController.openedFactor,
  ];

  void toEditor(String name) {
    //
    final bindings = EditorBindings.paged(
      page: page,
      service: name,
    );

    to(
      () => Editor(bindings: bindings),
      binding: bindings,
      onOpen: video.player.pause,
      onClose: video.reload,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scroll = useScrollController();

    return SnappingSheet(
      controller: sheet.controller,
      onSheetMoved: sheet.onSheetMoved,
      lockOverflowDrag: true,
      initialSnappingPosition: snaps.first,
      snappingPositions: snaps,
      grabbingHeight: -1,
      sheetAbove: SnappingSheetContent(
        draggable: (_) => !gesture.zoomed,
        child: child,
      ),
      sheetBelow: SnappingSheetContent(
        draggable: (_) => true,
        childScrollController: scroll,
        child: Material(
          child: SafeArea(
            top: false,
            child: Obx(() {
              //
              if (sheet.showServices.value) {
                return ServiceList(
                  page.current.tags,
                  controller: scroll,
                  onTap: toEditor,
                );
              }

              return GenericListView(
                items: page.current.all.display.toList(),
                scrollController: scroll,
                itemBuilder: (context, tag) {
                  return TagTile(
                    tag: tag,
                    onTap: Tag.toClipboard,
                  );
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}
