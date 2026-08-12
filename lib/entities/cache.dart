import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file.dart';


class FileCache extends DelegatingMapBase<int, HydrusFile> {

  final cache = <int, HydrusFile>{};

  @override
  Map<int, HydrusFile> get delegate => cache;

  final deleted = <int>[].rx;

  /// Remove files with provided [ids].
  Future<void> removeWithIds(List<int> ids) async {

    final toRemove = ids.map((id) => cache[id]!);

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
