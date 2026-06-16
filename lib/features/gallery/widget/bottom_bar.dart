import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/reactive/file_store.dart';

import '../getx/selection.dart';


class SelectionBottomBar extends StatelessWidget {
  final String tag;
  final bool show;
  final void Function(int index)? onEdit;
  final void Function(FileStore files, List<int> ids)? onBatchEdit;

  const SelectionBottomBar({
    super.key,
    required this.tag,
    this.show = true,
    this.onEdit,
    this.onBatchEdit,
  });

  @override
  Widget build(BuildContext context) {
    final FileStore files = Get.find(tag: tag);
    final SelectionController selection = Get.find(tag: tag);

    return AnimatedSlide(
      curve: Curves.easeOutCubic,
      duration: const Duration(milliseconds: 250),
      offset: show ? .zero : const Offset(0, 1),
      child: BottomAppBar(
        color: Get.theme
            .scaffoldBackgroundColor
            .withAlpha(90),
        padding: const .fromLTRB(10, 0, 10, 0),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Counter(count: selection.ids.length),

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
                      onEdit?.call(index);
                    case _:
                      final ids = selection.ids.toList();
                      onBatchEdit?.call(
                        FileStore.pickFrom(files, ids),
                        ids,
                      );
                  }
                },
              ),

              Obx(() {
                return SelectAllButton(
                  selected: selection.selectedAll,
                  select: selection.selectAll,
                  clear: selection.clear,
                );
              }),

              Obx(() {
                switch (selection.rangeSelected) {
                  case true:
                    return IconButton(
                      tooltip: 'Select range',
                      icon: const Icon(Symbols.fit_width),
                      color: Colors.white,
                      onPressed: selection.selectRange,
                    );
                  case false:
                    return const SizedBox.shrink();
                }
              }),

            ])
              ..gap = 10
          ],
        ),
      ),
    );
  }
}


class Counter extends StatelessWidget {
  final int count;

  const Counter({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const .fromLTRB(22, 0, 10, 0),
      child: Material(
        borderRadius: .circular(12),
        color: colors.error,
        child: '$count'.n
          ..titleMedium
          ..color = colors.onError
          ..n.padding = const .fromLTRB(8, 0, 8, 0),
      ),
    );
  }
}


class SelectAllButton extends StatelessWidget {
  final bool selected;
  final void Function()? select;
  final void Function()? clear;

  const SelectAllButton({
    super.key,
    required this.selected,
    this.select,
    this.clear,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: selected ? 'Clear selection' : 'Select all',
      icon: selected
          ? const Icon(Symbols.select)
          : const Icon(Symbols.select_all),
      color: Colors.white,
      onPressed: selected ? clear : select,
    );
  }
}


