import 'package:get/get.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file.dart';


class FileCache {

  final cache = <int, HydrusFile>{};

  /// Subscribe to this [Rx] with [Worker] to get
  /// notified on file deletion.
  final deleted = <int>[].rx;

  HydrusFile? operator [](int id) => cache[id];

  void assignAll(Map<int, HydrusFile> val) => cache.assignAll(val);

  void addAll(Map<int, HydrusFile> val) => cache.addAll(val);

  void clear() => cache.clear();

  /// Remove files with provided [ids].
  ///
  /// Use [getOffAll] when deleting the last file to
  /// get to the home screen.
  Future<void> remove(List<int> ids, {
    bool getOffAll = false,
  }) async {

    final toRemove = ids.map((id) => cache[id]!);

    for (final file in toRemove) {
      file.removing = true;
    }

    if (getOffAll) {
      Get.until((route) => route.isFirst);
      await sleep(transition);
    }

    for (final file in toRemove) {
      file.remove();
    }

    await sleep(deletionDuration + 100.ms);

    deleted.value = ids;

    for (final file in toRemove) {
      cache.remove(file.id);
    }
  }
}
