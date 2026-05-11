import 'package:get/get.dart';
import 'package:hydrus_flutter/core/domain/entities.dart';


class FileRepo extends GetxController {
  final RxList<HydrusFile> _files;

  /// Initialize empty [FileRepo]
  FileRepo() : _files = <HydrusFile>[].obs;

  /// Takes files from [fileRepo] with specified [ids] and
  /// created a new [FileRepo].
  ///
  /// New [FileRepo] will have the same [HydrusFile] objects as
  /// the original and will impact the original [FileRepo].
  FileRepo.pickFrom(FileRepo fileRepo, List<int> ids)
    : _files = fileRepo.byIds(ids).obs;

  int get length => _files.length;

  HydrusFile operator [](int index) => _files[index];

  void clear() => _files.clear();

  void assignAll(Iterable<HydrusFile> items) => _files.assignAll(items);

  int indexWhere(bool Function(HydrusFile) test, [int start = 0]) {
    return _files.indexWhere(test, start);
  }

  HydrusFile? byId(int id) {
    return _files.firstWhereOrNull((f) => f.id == id);
  }

  List<HydrusFile> byIds(List<int> ids) => ids
      .map((id) => byId(id))
      .whereType<HydrusFile>()
      .toList();
}