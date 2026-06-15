import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/editor/bindings.dart';

import '../getx/gallery.dart';
import '../getx/selection.dart';


class HidableBottomBar extends StatelessWidget {
  final String tag;
  final Widget child;
  final bool show;

  const HidableBottomBar({
    super.key,
    required this.tag,
    required this.child,
    required this.show,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      curve: Curves.easeOutCubic,
      duration: const Duration(milliseconds: 250),
      offset: show ? .zero : const Offset(0, 1),
      child: Wrap(
        children: [
          SelectActions(tag: tag),
        ],
      ),
    );
  }
}


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
              switch (selection.ids.length) {
                case 1:
                  final id = selection.ids.first;
                  final index = files.indexWhere((f) => f.id == id);

                  EditorPage(files)
                      .paged(index, gallery)
                      .onClose(selection.clear)
                      .push();

                case _:
                  final ids = selection.ids.toList();
                  final subFiles = FileStore.pickFrom(files, ids);

                  EditorPage(subFiles)
                      .batch(gallery, ids)
                      .onClose(selection.clear)
                      .push();
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
