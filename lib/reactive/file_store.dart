import 'package:dartx/dartx.dart';
import 'package:get/get.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file.dart';


class FileStore {
  final RxList<int> ids;
  final RxMap<int, HydrusFile> cache;

  FileStore() : ids = .new(), cache = .new();

  FileStore.fromMap(Map<int, HydrusFile> map)
      : ids = map.keys.toList().obs,
        cache = map.obs;

  FileStore copy() => FileStore.fromMap(cache);

  FileStore copyWithIds(Iterable<int> ids) {
    final map = cache.withIds(ids);
    return FileStore.fromMap(map);
  }

  factory FileStore.single(HydrusFile file) {
    return FileStore.fromMap({file.id: file});
  }

  HydrusFile operator [](int index) => cache[ids[index]]!;

  int get length => cache.length;

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
