import 'package:get/get.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/utils/utils.dart';


class FileCache extends DelegatingMapBase<int, HydrusFile> {

  final cache = <int, HydrusFile>{};

  @override
  Map<int, HydrusFile> get delegate => cache;

  final stream = GetStream<Iterable<int>>();

  /// Remove files with provided [ids].
  Future<void> removeWithIds(List<int> ids) async {

    final toRemove = ids.map((id) => cache[id]!);

    for (final file in toRemove) {
      file.delete();
    }

    await sleep(deletionDuration + 100.ms);

    stream.add(ids);

    for (final file in toRemove) {
      cache.remove(file.id);
    }
  }
}
