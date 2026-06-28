import 'dart:ui';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/entities/tag.dart';
import 'package:niku/namespace.dart' as n;
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

import 'package:hydit/widgets/tag_list.dart';
import 'package:hydit/reactive/file_store.dart';

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
  SnappingSheetController get sheet => Get.find(tag: tag);

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
      controller: sheet,
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
              final meta = files[page.i].meta;

              if (meta == null) {
                return SkeletonListView(scroll);
              }

              if (page.showServices.value) {
                final tags = Map<String, Set<Tag>>.from(meta.combined)
                  ..remove('all known tags');

                final keys = tags.keys.toList();
                final vals = tags.values.toList();

                return ListView.builder(
                  padding: .zero,
                  itemCount: tags.length,
                  controller: scroll,
                  itemBuilder: (context, index) {
                    final name = keys[index];
                    final count = vals[index].length;

                    return ListTile(
                      title: Text(name),
                      trailing: Row(
                        spacing: 5,
                        mainAxisSize: .min,
                        children: [
                          ?count > 0 ? Badge(label: Text('$count')) : null,
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    );
                  },
                );
              }

              return TagList(
                tags: meta.all.toList(),
                scrollController: scroll,
                itemBuilder: (context, tag) => TagTile(tag: tag),
              );
            }),
          ),
        ]),
      ),
    );
  }
}


class SkeletonListView extends StatelessWidget {
  final ScrollController scroll;

  const SkeletonListView(this.scroll, {super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Skeletonizer(
        child: ListView.builder(
          itemCount: 8,
          controller: scroll,
          itemBuilder: (context, index) {
            return ListTile(title: Text('X' * 16));
          },
        ),
      ),
    );
  }
}
