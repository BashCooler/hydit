import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

import 'package:hydrus_flutter/utils/theme.dart';
import 'package:hydrus_flutter/core/ui/tag_list.dart';
import 'package:hydrus_flutter/core/domain/entities.dart';
import 'package:hydrus_flutter/features/search/getx/query.dart';
import 'package:hydrus_flutter/features/editor/page/editor.dart';

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
        .factor(positionFactor: 0.0),
        .factor(positionFactor: 0.5),
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

  void openEditor() => Get.to(() => Editor(tag: tag),
    transition: .topLevel,
    duration: AppTheme.duration,
    curve: Curves.easeInOutCubic,
    binding: BindingsBuilder.put(
      () => QueryController(),
      tag: 'Editor',
    ),
  );

  @override
  Widget build(BuildContext context) {

    final scrollBelow = useScrollController();
    final SnappingSheetController sheet = Get.find(tag: tag);
    final PageGetxController page = Get.find(tag: tag);

    const background = Material(child: Center());

    return SnappingSheet(
      controller: sheet,
      onSheetMoved: syncPageLock,
      lockOverflowDrag: true,
      initialSnappingPosition: .factor(positionFactor: 0.0),
      snappingPositions: snaps,
      grabbingHeight: -1,
      sheetAbove: SnappingSheetContent(
        draggable: (_) => !page.zoom.value,
        child: child,
      ),
      sheetBelow: SnappingSheetContent(
        draggable: (_) => true,
        childScrollController: scrollBelow,
        child: Stack(
          children: [
            background,
            SafeArea(
              top: false,
              child: ClipRect(
                child: Scaffold(
                  body: TagList(
                    scrollController: scrollBelow,
                    tags: tags,
                  ),
                  floatingActionButton: Padding(
                    padding: const .only(bottom: 18),
                    child: FloatingActionButton(
                      onPressed: openEditor,
                      child: const Icon(Icons.edit_note),
                    ),
                  ),
                  floatingActionButtonLocation: .miniEndFloat,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
