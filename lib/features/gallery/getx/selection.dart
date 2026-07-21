import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/extra/primitive.dart';

import 'package:hydit/utils/utils.dart';
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
    if (ids.length != 2) return false;  // important

    final r = _range();

    if (r == null) return false;

    return r.$2 - r.$1 > 1;
  }

  void select(int id, int index) {
    if (!gallery.loading.value) {
      ids.contains(id) ? ids.remove(id) : ids.add(id);
    }
  }

  bool isSelected(int id) => ids.contains(id);

  void clear() => ids.clear();

  void selectRange() {
    final r = _range();

    if (r == null) return;

    final lastId = ids.last;
    ids.remove(lastId);

    for (int i = r.$1; i < r.$2; i++) {
      ids.add(files[i].id);
    }

    ids.add(lastId);
  }

  (int, int)? _range() {
    if (ids.length != 2) return null;

    final indices = [
      files.ids.indexOf(ids.first),
      files.ids.indexOf(ids.last),
    ];

    if (indices.length < 2) return null;

    indices.sort();

    return (indices.first, indices.last);
  }

  void selectAll() => ids.addAll(files.ids);

  // MARK: EDIT

  void edit() async {
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

    EditorPage(files)
        .paged(page)
        .onClose(clear)
        .push();
  }

  void _openBatchEditor() async {
    final token = CancellationToken();

    Get.dialog(
      transitionDuration: 150.ms,
      barrierDismissible: false,
      Obx(
        () => ProgressDialog(
          progress: files.length,
          full: ids.length,
          title: 'Loading metadata...'.n,
          token: token,
        ),
      ),
    );

    final result = await loader
        .ensureLoaded(ids, token)
        .tapFailure(Snack.error);

    Get.back();

    if (result is Failure || token.cancelled) {
      return;
    }

    EditorPage(files.copyWithIds(ids))
        .batch(ids)
        .onClose(clear)
        .push();
  }

  // MARK: DELETE

  void delete() {

    void onSuccess(void value) {
      Get.back();
      files.removeWithIds(ids);
      clear();
    }

    Future<Result<void>> onApply() => repo.api
        .deleteFiles(ids.toList())
        .run()
        .tapSuccess(onSuccess)
        .tapFailure(Snack.error);

    final dialog = LoadingDialogBuilder()
      ..icon = const Icon(Icons.delete_forever)
      ..title = 'Delete files?'.n
      ..loadingTitle = 'Deleting...'.n
      ..onApply = onApply;

    dialog.show();
  }

  // MARK: DOWNLOAD

  Future<void> download({double delay = 0}) async {
    final files = this.files.withIds(ids);

    final progress = 0.obs;
    final token = CancellationToken();

    Get.dialog(
      transitionDuration: 150.ms,
      barrierDismissible: false,
      Obx(() {
        return ProgressDialog(
          progress: progress.value,
          full: files.length,
          title: 'Downloading files...'.n,
          token: token,
        );
      }),
    );

    for (final file in files) {

      if (token.cancelled) return;

      final download = file
          .download()
          .tapSuccess((_) => progress.value++)
          .tapFailure(Snack.error);

      final result = await Future.wait([
        download,
        sleep(delay.s),
      ]);

      if (result is Failure) return;
    }

    Get.back();
    Snack.success('Success', 'Files saved to downloads');
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

    final dialog = LoadingDialogBuilder()
      ..icon = const Icon(Icons.archive_outlined)
      ..title = 'Archive files?'.n
      ..onApply = onApply;

    dialog.show();
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

    final dialog = LoadingDialogBuilder()
      ..icon = const Icon(Icons.archive_outlined)
      ..title = 'Inbox files?'.n
      ..onApply = onApply;

    dialog.show();
  }
}
