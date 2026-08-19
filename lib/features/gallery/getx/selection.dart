import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/utils/utils.dart';
import 'package:niku/extra/primitive.dart';

import 'package:hydit/reactive/file.dart';
import 'package:hydit/services/services.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/widgets/common/dialog.dart';
import 'package:hydit/features/editor/bindings.dart';
import 'package:hydit/features/viewer/getx/page.dart';

import 'gallery.dart';


class SelectionController extends GetxController {
  final ids = <int>{}.obs;

  final String tag;

  Loader get loader => Get.find(tag: tag);
  FileStore get files => Get.find(tag: tag);
  GalleryController get gallery => Get.find(tag: tag);

  SelectionController({required this.tag});

  Repo repo = Get.find();

  // MARK: SELECTION

  bool get on => ids.isNotEmpty;

  bool get off => ids.isEmpty;

  bool get selectedAll => ids.length == files.ids.length;

  bool get selectedRange {
    if (ids.length != 2) return false;

    return files.ids
        .range(ids.first, ids.last)
        .let((it) => it.length > 2);
  }

  void select(int id, int index) {
    if (!gallery.loading.value) {
      ids.contains(id) ? ids.remove(id) : ids.add(id);
    }
  }

  bool isSelected(int id) => ids.contains(id);

  void clear() => ids.clear();

  void selectRange() {
    assert(ids.length == 2);

    files.ids
        .range(ids.first, ids.last)
        .also(ids.assignAll);
  }

  void selectAll() => ids.assignAll(files.ids);

  // MARK: EDIT

  void edit() {
    switch (ids.length) {
      case 1:
        _openPagedEditor();
      case > 1:
        _openBatchEditor();
    }
  }

  void _openPagedEditor() {

    final page = PageGetxController(
      files: files,
      initial: files.ids.indexOf(ids.first),
    );

    EditorPage.paged(
      page: page,
      service: 'my tags',
      onClose: clear,
    );
  }

  void _openBatchEditor() async {
    final token = CancellationToken();

    ProgressDialog.show(
      title: 'Loading metadata...'.n,
      token: token,
      full: ids.length,
      progress: () => files.length,
    );

    final result = await loader
        .ensureLoaded(ids, token)
        .tapFailure(Snack.error);

    Get.back();

    if (result is Failure || token.cancelled) {
      return;
    }

    EditorPage.batch(
      ids: ids.toList(),
      onClose: clear,
    );
  }

  // MARK: DELETE

  void delete() {

    void onSuccess(void value) {
      Get.back();
      files.cache.remove(ids.toList());
      clear();
    }

    Future<Result<void>> onApply() => repo.api
        .deleteFiles(ids.toList())
        .run()
        .tapSuccess(onSuccess)
        .tapFailure(Snack.error);

    LoadingDialog.show(
      icon: const Icon(Icons.delete_forever),
      title: 'Delete files?'.n,
      loadingTitle: 'Deleting...'.n,
      onApply: onApply,
    );
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

      final download = await repo
          .download(id)
          .tapSuccess((_) => progress.value++)
          .delay(delay);

      if (download is Failure) {
        token.cancel();
      }

      if (token.cancelled) {
        Get.back();
        return download;
      }
    }

    Get.back();

    return Success(null);
  }

  // MARK: ARCHIVE

  void archive() {
    final loaded = ids
        .map((id) => files.cache[id])
        .whereType<HydrusFile>();

    void onSuccess(void data) {
      for (final file in loaded) {
        file.inbox.value = false;
      }
      Get.back();
    }

    Future<Result<void>> onApply() => repo.api
        .archiveFiles(ids.toList())
        .run()
        .tapSuccess(onSuccess)
        .tapFailure(Snack.error);

    LoadingDialog.show(
      icon: const Icon(Icons.archive_outlined),
      title: 'Archive files?'.n,
      onApply: onApply,
    );
  }

  void inbox() {
    final loaded = ids
        .map((id) => files.cache[id])
        .whereType<HydrusFile>();

    void onSuccess(void data) {
      for (final file in loaded) {
        file.inbox.value = true;
      }
      Get.back();
    }

    Future<Result<void>> onApply() => repo.api
        .unarchiveFiles(ids.toList())
        .run()
        .tapSuccess(onSuccess)
        .tapFailure(Snack.error);

    LoadingDialog.show(
      icon: const Icon(Icons.mail_outline),
      title: 'Inbox files?'.n,
      onApply: onApply,
    );
  }
}
