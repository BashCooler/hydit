import 'dart:collection';

import 'package:get/get.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file.dart';


class FileStore with IterableMixin<HydrusFile> {
  final RxList<int> ids;
  final RxList<HydrusFile> rx;

  /// Create empty [FileStore].
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

  FileStore.copy(FileStore store)
      : ids = store.ids,
        rx = store.rx;

  FileStore copy() => FileStore.copy(this);

  HydrusFile operator [](int index) => rx[index];

  @override
  Iterator<HydrusFile> get iterator => rx.iterator;

  @override
  int get length => rx.length;

  /// The first index in the list with provided [id].
  /// Returns -1 if element is not found.
  int indexById(int id) {
    return ids.indexWhere((e) => e == id);
  }

  /// The first element with provided [id].
  /// If no file is found throws [StateError].
  HydrusFile byId(int id) {
    return rx.firstWhere((f) => f.id == id);
  }

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
