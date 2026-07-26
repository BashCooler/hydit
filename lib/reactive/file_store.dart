import 'package:dartx/dartx.dart';
import 'package:get/get.dart';
import 'package:hydit/entities/cache.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file.dart';


class FileStore {
  /// All files in this store, loaded and not.
  final RxList<int> ids;

  final Rx<int> _loaded;

  /// The number of loaded files.
  int get length => _loaded.value;

  FileStore(Iterable<int> ids)
      : ids = .of(ids),
        _loaded = ids.length.obs;

  FileStore.empty()
      : ids = .empty(growable: true),
        _loaded = 0.obs;

  FileStore copy() => FileStore(ids);

  FileCache get cache => Get.find();

  HydrusFile operator [](int index) => cache[ids[index]]!;

  void commit(Iterable<HydrusFile> files, {
    bool clear = false,
  }) {

    final map = files.toMap();

    if (clear) {
      cache.assignAll(map);
      _loaded.value = map.length;
    } else {
      cache.addAll(map);
      _loaded.value += files.length;
    }
  }

  /// Files with provided [ids].
  Iterable<HydrusFile> withIds(Iterable<int> ids) {
    return ids.map((id) => cache[id]!);
  }

  /// Remove files with provided [ids].
  Future<void> removeWithIds(List<int> ids) async {
    final toRemove = cache.withIds(ids).values;

    for (final file in toRemove) {
      file.delete();
    }

    await sleep(deletionDuration + 100.ms);

    for (final file in toRemove) {
      cache.remove(file.id);
    }

    for (final id in ids) {
      this.ids.remove(id);
    }
  }
}

extension ByIds on Map<int, HydrusFile> {

  Map<int, HydrusFile> withIds(Iterable<int> ids) {
    return filterValues((file) => ids.contains(file.id));
  }
}


extension ToMap on Iterable<HydrusFile> {
  /// The ids to files [Map].
  Map<int, HydrusFile> toMap() => Map.fromIterable(
    this,
    key: (file) => file.id,
  );
}
