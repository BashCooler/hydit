import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/widgets/systems/acrylic.dart' as a;
import 'package:hydit/widgets/systems/gradient.dart';

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
  Widget build(BuildContext context) => Obx(() {
    return IgnorePointer(
      ignoring: selection.off,
      child: GradientBottomAppBar(
        child: AnimatedOpacity(
          curve: Curves.easeOutCubic,
          duration: 250.ms,
          opacity: selection.on ? 1 : 0,
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              a.Pill.text(
                children: [
                  a.Text(selection.ids.length),
                ],
              ),
              a.Pill(
                children: [
                  SelectAllButton(tag: tag),
                  IconButton(
                    tooltip: 'Edit tags',
                    icon: const Icon(Symbols.edit_square),
                    onPressed: selection.edit,
                  ),
                  SelectRangeButton(tag: tag),
                  a.More([
                    PopupMenuItem(
                      onTap: selection.delete,
                      child: 'delete'.n,
                    ),

                    PopupMenuItem(
                      padding: const .only(left: 12),
                      onTap: selection.download,
                      child: Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          'download'.n,
                          IconButton(
                            tooltip: 'Download 1 file per second',
                            icon: Icon(Symbols.chronic),
                            onPressed: () {
                              selection.download(delay: 1);
                            },
                          ),
                        ],
                      ),
                    ),

                    PopupMenuItem(
                      onTap: selection.archive,
                      child: 'archive'.n,
                    )
                  ]),
                ],
              ),
            ],
          ),
        ),
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

    if (!selection.selectedRange) {
      return const SizedBox.shrink();
    }

    return IconButton(
      tooltip: 'Select range',
      icon: const Icon(Symbols.fit_width),
      onPressed: selection.selectRange,
    );
  });
}
