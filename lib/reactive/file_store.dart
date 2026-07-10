import 'dart:collection';

import 'package:get/get.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/services/services.dart';

import 'file.dart';


class FileStore with IterableMixin<HydrusFile> {
  final RxList<int> ids;
  final RxList<HydrusFile> rx;

  final Repo repo = Get.find();

  /// Create empty [FileStore]
  FileStore(): ids = .new(), rx = .new();

  /// Takes files from [store] with specified [ids] and
  /// created a new [FileStore].
  ///
  /// New [FileStore] will have the same [HydrusFile] objects as
  /// the original and will impact the original [FileStore].
  FileStore.pickFrom(FileStore store, List<int> ids)
      : ids = .new(),
        rx = store.byIds(ids).obs {
    this.ids.assignAll(rx.map((f) => f.id));
  }

  /// Create file repo with the same files as given [store].
  ///
  /// The copy and the original [FileStore] share the same list, so
  /// all the changes in the copy will affect the original.
  FileStore.copy(FileStore store)
      : ids = store.ids,
        rx = store.rx;

  HydrusFile operator [](int index) => rx[index];

  @override
  Iterator<HydrusFile> get iterator => rx.iterator;

  @override
  int get length => rx.length;

  /// Create file repo with the same files as given [fileRepo].
  ///
  /// The copy and the original [FileStore] share the same list, so
  /// all the changes in the copy will affect the original.
  FileStore copy() => FileStore.copy(this);

  /// The first index in the list that satisfies the provided test.
  /// Returns -1 if element is not found.
  int indexWhere(bool Function(HydrusFile) test, [int start = 0]) {
    return rx.indexWhere(test, start);
  }

  /// The first index in the list with provided [id].
  /// Returns -1 if element is not found.
  int indexById(int id) {
    return indexWhere((e) => e.id == id);
  }

  /// The first element with provided [id].
  /// If no file is found throws [StateError].
  HydrusFile byId(int id) {
    return rx.firstWhere((f) => f.id == id);
  }

  /// Load and write metadata fot file with provided [id].
  ///
  /// This method is safe and can be continued with `onSuccess`,
  /// `onFailure` and other fluent API methods.
  Future<Result<void>> updateById(int id) => byId(id).update();

  /// Find all files with provided [ids].
  List<HydrusFile> byIds(Iterable<int> ids) => ids
      .map(byId)
      .whereType<HydrusFile>()
      .toList();

  /// Remove files with provided [ids].
  Future<void> removeWithIds(Iterable<int> ids) async {
    final toRemove = rx
        .where((file) => ids.contains(file.id))
        .toList();

    for (final file in toRemove) {
      file.delete();
    }

    await sleep(deletionDuration + 100.ms);

    for (final file in toRemove) {
      rx.remove(file);
      this.ids.remove(file.id);
    }
  }
}
