import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/core/state/files.dart';
import 'package:hydit/features/editor/getx/bindings.dart';

import '../getx/gallery.dart';
import '../getx/selection.dart';


class SelectActions extends StatelessWidget {
  final String tag;

  const SelectActions({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final FileStore files = Get.find(tag: tag);
    final SelectionController selection = Get.find(tag: tag);
    final GalleryController gallery = Get.find(tag: tag);

    return BottomAppBar(
      color: Get.theme.scaffoldBackgroundColor.withAlpha(90),
      child: n.Row([
        Obx(() {
          return '${selection.ids.length} selected'.n
            ..expanded
            ..color = Colors.white
            ..fontSize = 16
            ..fontWeight = .w500
            ..shadows = [Shadow(blurRadius: 24)]
            ..textAlign = .center;
        }),
        n.Row([
          IconButton(
            tooltip: 'Edit tags',
            icon: const Icon(Icons.edit),
            color: Colors.white,
            onPressed: () async {
              final tag = 'Editor-${DateTime.now().microsecondsSinceEpoch}';
              switch (selection.ids.length) {
                case 1:
                  final id = selection.ids.first;
                  final index = files.indexWhere((f) => f.id == id);
                  await toEditorPaged(tag, index, files, gallery);
                  selection.clear();
                case _:
                  final ids = selection.ids.toList();
                  final fileRepo = FileStore.pickFrom(files, ids);
                  await toEditorBatch(tag, fileRepo, gallery, ids);
                  selection.clear();
              }
            },
          ),
          Obx(() {
            switch (selection.rangeSelected) {
              case true:
                return IconButton(
                  tooltip: 'Select range',
                  icon: const Icon(Icons.select_all),
                  color: Colors.white,
                  onPressed: selection.selectRange,
                );
              case false:
                return const SizedBox.shrink();
            }
          }),
        ])
          ..gap = 10
          ..padding = const .only(right: 10),
      ])
        ..mainAxisAlignment = .spaceBetween,
    );
  }
}