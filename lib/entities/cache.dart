import 'package:get/get.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file.dart';


class FileCache extends DelegatingMapBase<int, HydrusFile> {

  final cache = <int, HydrusFile>{};

  @override
  Map<int, HydrusFile> get delegate => cache;

  final deleted = <int>[].rx;

  /// Remove files with provided [ids].
  ///
  /// Use [getOffAll] when deleting the last file to
  /// get to the home screen.
  Future<void> removeWithIds(List<int> ids, {
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
