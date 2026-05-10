import 'package:get/get.dart';
import 'package:hydrus_flutter/core/domain/entities.dart';


class FileRepo extends GetxController {
  final files = <HydrusFile>[].obs;

  int get length => files.length;
  HydrusFile operator [](int index) => files[index];

  void clear() => files.clear();

  void assignAll(Iterable<HydrusFile> items) => files.assignAll(items);

  int indexWhere(bool Function(HydrusFile) test, [int start = 0]) {
    return files.indexWhere(test, start);
  }

  HydrusFile? byId(int id) {
    return files.firstWhereOrNull((f) => f.id == id);
  }
}