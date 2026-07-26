import 'package:get/get.dart';
import 'package:hydit/entities/cache.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file.dart';


class FileStore {
  /// All files in this store, loaded and not.
  final RxList<int> ids;

  final RxList<int> loaded;

  /// The number of loaded files.
  int get length => loaded.length;

  FileStore(Iterable<int> ids) : ids = .of(ids), loaded = .of(ids);

  FileStore.empty() : ids = .new(), loaded = .new();

  FileStore copy() => FileStore(ids);

  FileCache get cache => Get.find();

  HydrusFile operator [](int index) => cache[ids[index]]!;

  void commit(Iterable<HydrusFile> files, {
    bool clear = false,
  }) {

    final ids = files.map((file) => file.id);
    final map = files.toMap();

    if (clear) {
      cache.assignAll(map);
      loaded.assignAll(ids);
    } else {
      cache.addAll(map);
      loaded.addAll(ids);
    }
  }

  /// Files with provided [ids].
  Iterable<HydrusFile> withIds(Iterable<int> ids) {
    return ids.map((id) => cache[id]!);
  }

  /// Remove files with provided [ids].
  Future<void> removeWithIds(List<int> ids) async {

    final toRemove = ids.map((id) => cache[id]!);

    for (final file in toRemove) {
      file.delete();
    }

    await sleep(deletionDuration + 100.ms);

    this.ids.removeWhere(ids.contains);

    loaded.removeWhere(ids.contains);

    for (final file in toRemove) {
      cache.remove(file.id);
    }
  }
}


extension ToMap on Iterable<HydrusFile> {
  /// The ids to files [Map].
  Map<int, HydrusFile> toMap() => Map.fromIterable(
    this,
    key: (file) => file.id,
  );
}
