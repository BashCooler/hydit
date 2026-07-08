import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/features/viewer/getx/page.dart';
import 'package:niku/extra/primitive.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/widgets/dialog.dart';
import 'package:hydit/services/services.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/editor/bindings.dart';

import 'gallery.dart';


class SelectionController extends GetxController {
  final ids = <int>{}.obs;
  final indices = <int>{};

  final String tag;

  FileStore get files => Get.find(tag: tag);
  GalleryController get gallery => Get.find(tag: tag);

  SelectionController({required this.tag});

  Repo repo = Get.find();

  bool get selectedAll => ids.length == files.length;

  bool get selectedRange {
    if (ids.length != 2) return false;  // important
    final r = range();
    return switch (r) {
      null => false,
      _ => r.$2 - r.$1 > 1,
    };
  }

  bool get on => ids.isNotEmpty;
  bool get off => ids.isEmpty;

  void clear() => ids.clear();

  bool isSelected(int id) => ids.contains(id);

  void selectTile(int id, int index) {
    if (gallery.loading.value) return;

    switch (ids.contains(id)) {
      case true:
        ids.remove(id);
        indices.remove(index);
      case false:
        ids.add(id);
        indices.add(index);
    }
  }

  void selectRange() {
    final r = range();
    if (r == null) return;

    final lastId = ids.last;
    ids.remove(lastId);

    for (int i = r.$1; i < r.$2; i++) {
      ids.add(files[i].id);
      indices.add(i);
    }

    ids.add(lastId);
  }

  void selectAll() {
    ids.addAll(files.ids);
    for (var i = 0; i < files.length; i++) {
      indices.add(i);
    }
  }

  (int, int)? range() {
    if (ids.length != 2) return null;

    final indices = <int>[
      files.indexById(ids.first),
      files.indexById(ids.last),
    ];

    if (indices.length < 2) return null;

    indices.sort();

    return (indices.first, indices.last);
  }

  void edit() async {
    switch (ids.length) {
      case 1:
        final index = files.indexById(ids.first);
        final page = PageGetxController(files: files, initial: index);

        EditorPage(files)
            .paged(page)
            .onClose(clear)
            .push();
      case _:
        final ids = this.ids.toList();

        final token = CancellationToken();

        loading(ids.length, token);

        final result = await this.files.loader!
            .ensureLoaded(indices, token)
            .tapFailure(Snack.error);

        Get.back();

        if (result is Failure || token.cancelled) {
          return;
        }

        final files = FileStore.pickFrom(this.files, ids);

        EditorPage(files)
            .batch(gallery, ids)
            .onClose(clear)
            .push();
    }
  }

  Future<void> delete() async {

    void onSuccess(void value) {
      Get.back();
      files.removeWithIds(ids);
      clear();
    }

    await Get.dialog(
      barrierDismissible: false,
      transitionDuration: 150.ms,
      LoadingDialog(
        icon: const Icon(Icons.delete_forever),
        title: 'Delete files?'.n,
        loadingTitle: 'Deleting...'.n,
        content: 'Selected files will be marked as deleted in Hydrus'.n,
        onApply: () {
          return repo.api
              .deleteFiles(ids.toList())
              .run()
              .tapSuccess(onSuccess)
              .tapFailure(Snack.error);
        },
      ),
    );
  }

  Future<void> loading(int full, CancellationToken token) {
    return Get.dialog(
      transitionDuration: 150.ms,
      Obx(() {
        return ProgressDialog(
          progress: files.rx.length,
          full: full,
          title: 'Loading metadata...'.n,
          token: token,
        );
      }),
    );
  }

  void download({double delay = 0}) async {
    final files = this.files.byIds(ids);

    final progress = 0.obs;
    final token = CancellationToken();

    Get.dialog(
      transitionDuration: 150.ms,
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

      final result = Future.wait([
        download,
        sleep(delay.s),
      ]);

      if (await result is Failure) return;
    }

    Get.back();
    Snack.success('Success', 'Files saved to downloads');
  }
}
