import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/utils/utils.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/reactive/file_store.dart';

import '../getx/selection.dart';


class SelectionBottomBar extends StatelessWidget {
  final String tag;
  final void Function(int index)? onEdit;
  final void Function(FileStore files, List<int> ids)? onBatchEdit;

  const SelectionBottomBar({
    super.key,
    required this.tag,
    this.onEdit,
    this.onBatchEdit,
  });

  FileStore get files => Get.find(tag: tag);
  SelectionController get selection => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      curve: Curves.easeOutCubic,
      duration: 250.ms,
      offset: selection.on ? .zero : const Offset(0, 1),
      child: BottomAppBar(
        color: Theme.of(context)
            .scaffoldBackgroundColor
            .withAlpha(90),
        padding: const .fromLTRB(10, 0, 10, 0),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Counter(tag: tag),
            Row(
              spacing: 10,
              children: [
                SelectAllButton(tag: tag),
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_forever),
                  color: const Color(0xFFFFFFFF),
                  onPressed: () async => await selection.delete(),
                ),
                IconButton(
                  tooltip: 'Edit tags',
                  icon: const Icon(Icons.edit),
                  color: const Color(0xFFFFFFFF),
                  onPressed: selection.edit,
                ),
                SelectRangeButton(tag: tag),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class Counter extends StatelessWidget {
  final String tag;

  const Counter({super.key, required this.tag});

  SelectionController get selection => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) => Obx(() {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const .fromLTRB(22, 0, 10, 0),
      child: Material(
        borderRadius: .circular(12),
        color: colors.error,
        child: '${selection.ids.length}'.n
          ..titleMedium
          ..color = colors.onError
          ..n.padding = const .fromLTRB(8, 0, 8, 0),
      ),
    );
  });
}


class SelectAllButton extends StatelessWidget {
  final String tag;
  final void Function()? select;
  final void Function()? clear;

  const SelectAllButton({
    super.key,
    required this.tag,
    this.select,
    this.clear,
  });

  SelectionController get selection => Get.find(tag: tag);
  bool get selected => selection.selectedAll;

  @override
  Widget build(BuildContext context) => Obx(() {
    return IconButton(
      tooltip: selected ? 'Clear selection' : 'Select all',
      icon: selected
          ? const Icon(Symbols.select)
          : const Icon(Symbols.select_all),
      color: Colors.white,
      onPressed: selected
          ? selection.clear
          : selection.selectAll,
    );
  });
}


class SelectRangeButton extends StatelessWidget {
  final String tag;

  const SelectRangeButton({super.key, required this.tag});

  SelectionController get selection => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) => Obx(() {
    if (!selection.selectedRange) return const Nothing();

    return IconButton(
      tooltip: 'Select range',
      icon: const Icon(Symbols.fit_width),
      color: Colors.white,
      onPressed: selection.selectRange,
    );
  });
}

