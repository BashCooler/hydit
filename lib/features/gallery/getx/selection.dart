import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/utils/utils.dart';
import 'package:niku/extra/primitive.dart';

import 'package:hydit/services/services.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/widgets/common/dialog.dart';
import 'package:hydit/features/editor/bindings.dart';
import 'package:hydit/features/editor/page/editor.dart';
import 'package:hydit/features/viewer/getx/page.dart';

import 'loader.dart';


class SelectionController({
  required final String tag,
  required final FileStore store,
  required final bool Function() enabled,
}) {
  final ids = <int>{}.obs;

  Loader get loader => Get.find(tag: tag);

  Api get api => Get.find();

  // MARK: SELECTION

  bool get on => ids.isNotEmpty;

  bool get off => ids.isEmpty;

  bool get selectedAll => ids.length == store.ids.length;

  bool get selectedRange {
    if (ids.length != 2) return false;

    return store.ids
        .range(ids.first, ids.last)
        .let((it) => it.length > 2);
  }

  void select(int id, int index) =>
      enabled()
          ? ids.contains(id) ? ids.remove(id) : ids.add(id)
          : null;

  bool isSelected(int id) => ids.contains(id);

  void clear() => ids.clear();

  void selectRange() {
    assert(ids.length == 2);

    store.ids
        .range(ids.first, ids.last)
        .also(ids.assignAll);
  }

  void selectAll() => ids.assignAll(store.ids);

  // MARK: EDIT

  void edit() => ids.length > 1 ? _openBatchEditor() : _openPagedEditor();

  void _openPagedEditor() async {

    final page = PageGetxController(
      files: store,
      initial: store.ids.indexOf(ids.first),
    );

    final bindings = EditorBindings.paged(
      page: page,
      service: 'my tags',
    );

    await Get.to(
      () => Editor(bindings: bindings),
      curve: Curves.easeInOutCubic,
      opaque: false,
      binding: bindings,
    );

    clear();
  }

  void _openBatchEditor() async {
    final token = CancellationToken();

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

    await Get.to(
      () => Editor(bindings: bindings),
      curve: Curves.easeInOutCubic,
      opaque: false,
      binding: bindings,
    );

    clear();
  }

  // MARK: DOWNLOAD

  Future<Result<void>> download({double delay = 0}) async {
    final ids = this.ids.toList();

    final progress = 0.obs;
    final token = CancellationToken();

    ProgressDialog.show(
      title: 'Downloading files...'.n,
      token: token,
      full: ids.length,
      progress: () => progress.value,
    );

    for (final id in ids) {
      //
      final download = await api
          .getFile(id)
          .save()
          .run()
          .withMinDuration(delay.s)
          .tapSuccess((_) => progress.value++)
          .tapFailure((_) => token.cancel());

      if (token.cancelled) {
        Get.back();
        return download;
      }
    }

    Get.back();

    return Success(null);
  }

  // MARK: DELETE

  void delete() {
    final ids = this.ids.toList();

    LoadingDialog.show(
      icon: const Icon(Icons.delete_forever),
      title: 'Delete files?'.n,
      loadingTitle: 'Deleting...'.n,
      onApply: () =>
          api.editFiles(ids, action: .delete).runMatch(
            ok: (v) {
              Get.back();
              store.cache.remove(ids);
              clear();
            },
            err: Snack.error,
          ),
    );
  }

  // MARK: ARCHIVE

  void archive() => setArchived(true);

  void inbox() => setArchived(false);

  Future<void> setArchived(bool archive) {
    final ids = this.ids.toList();

    final loaded = store.cache.withIds(ids);

    return LoadingDialog.show(
      icon: archive
          ? const Icon(Icons.archive_outlined)
          : const Icon(Icons.mail_outline),
      title: archive
          ? const Text('Archive files?')
          : const Text('Inbox files'),
      onApply: () =>
          api.editFiles(
            ids,
            action: archive ? .archive : .inbox,
          ).runMatch(
            ok: (v) {
              for (final file in loaded) {
                file.inbox.value = archive.not();
              }
              Get.back();
            },
            err: Snack.error,
          ),
    );
  }
}
