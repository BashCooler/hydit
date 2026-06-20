import 'package:get/get.dart';

import '../services/executor.dart';
import 'file.dart';


class FileStore {
  final RxList<HydrusFile> _files;

  /// Create empty [FileStore]
  FileStore() : _files = <HydrusFile>[].obs;

  /// Takes files from [store] with specified [ids] and
  /// created a new [FileStore].
  ///
  /// New [FileStore] will have the same [HydrusFile] objects as
  /// the original and will impact the original [FileStore].
  FileStore.pickFrom(FileStore store, List<int> ids)
    : _files = store.byIds(ids).obs;

  /// Create file repo with the same files as given [fileRepo].
  ///
  /// The copy and the original [FileStore] share the same list, so
  /// all the changes in the copy will affect the original.
  FileStore.copy(FileStore fileRepo) : _files = fileRepo._files;

  int get length => _files.length;

  HydrusFile operator [](int index) => _files[index];

  void clear() => _files.clear();

  void assignAll(Iterable<HydrusFile> items) => _files.assignAll(items);

  int indexWhere(bool Function(HydrusFile) test, [int start = 0]) {
    return _files.indexWhere(test, start);
  }

  int? indexById(int id) {
    final index = indexWhere((e) => e.id == id);
    return index > -1 ? index : null;
  }

  HydrusFile byId(int id) {
    return _files.firstWhere((f) => f.id == id);
  }

  Future<Result<void>> updateById(int id) => byId(id).update();

  List<HydrusFile> byIds(List<int> ids) => ids
      .map((id) => byId(id))
      .whereType<HydrusFile>()
      .toList();

  FileStore copy() => FileStore.copy(this);
}
