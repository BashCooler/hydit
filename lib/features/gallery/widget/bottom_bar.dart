import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/services/services.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/widgets/common/dialog.dart';
import 'package:hydit/widgets/systems/acrylic.dart' as a;
import 'package:hydit/widgets/systems/gradient.dart';
import 'package:hydit/features/viewer/getx/page.dart';
import 'package:hydit/features/editor/bindings.dart';
import 'package:hydit/features/editor/page/editor.dart';

import '../getx/loader.dart';
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

  void download({double delay = 0}) {

    void onSuccess(void data) {
      Snack.success('Success', 'Files saved to downloads');
    }

    selection
        .download(delay: delay)
        .tapSuccess(onSuccess)
        .tapFailure(Snack.error);
  }

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
                  EditButton(tag: tag),
                  SelectRangeButton(tag: tag),
                  a.More([
                    PopupMenuItem(
                      onTap: selection.delete,
                      child: 'delete'.n,
                    ),

                    PopupMenuItem(
                      padding: const .only(left: 12),
                      onTap: download,
                      child: Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          'download'.n,
                          IconButton(
                            tooltip: 'Download 1 file per second',
                            icon: Icon(Symbols.chronic),
                            onPressed: () {
                              Get.back();
                              download(delay: 1);
                            },
                          ),
                        ],
                      ),
                    ),

                    PopupMenuItem(
                      onTap: selection.inbox,
                      child: 'inbox'.n,
                    ),

                    PopupMenuItem(
                      onTap: selection.archive,
                      child: 'archive'.n,
                    ),
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


class EditButton extends StatelessWidget {
  final String tag;

  const EditButton({super.key, required this.tag});

  SelectionController get selection => Get.find(tag: tag);

  FileStore get store => Get.find(tag: tag);

  Loader get loader => Get.find(tag: tag);

  void edit() => selection.ids.length > 1 ? toBatchEditor() : toPagedEditor();

  void toPagedEditor() {
    //
    final page = PageGetxController(
      files: store,
      initial: store.ids.indexOf(selection.ids.first),
    );

    final bindings = EditorBindings.paged(
      page: page,
      service: 'my tags',
    );

    to(
      () => Editor(bindings: bindings),
      binding: bindings,
      onClose: selection.clear,
    );
  }

  void toBatchEditor() async {
    final token = CancellationToken();

    final ids = selection.ids;

    ProgressDialog.show(
      title: 'Loading metadata...'.n,
      token: token,
      full: ids.length,
      progress: () => store.length,
    );

    final result = await loader
        .ensureLoaded(ids, token: token)
        .tapFailure(Snack.error);

    Get.back();

    if (result is Failure || token.cancelled) {
      return;
    }

    final bindings = EditorBindings.batch(
      files: store.cache.withIds(ids),
    );

    to(
      () => Editor(bindings: bindings),
      binding: bindings,
      onClose: selection.clear,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Edit tags',
      icon: const Icon(Symbols.edit_square),
      onPressed: edit,
    );
  }
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
