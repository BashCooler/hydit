import 'dart:developer';

import 'package:get/get.dart';
import 'package:hydrus_flutter/core/domain/file_repo.dart';


class SelectionController extends GetxController {
  final ids = <int>{}.obs;

  bool get rangeSelected => ids.length == 2;

  bool get on => ids.isNotEmpty;

  void toggle(int id) {
    switch (ids.contains(id)) {
      case true:
        ids.remove(id);
      case false:
        ids.add(id);
    }
  }

  void clear() => ids.clear();

  bool isSelected(int id) => ids.contains(id);

  void selectRange() {
    if (!rangeSelected) return;
    final FileRepo files = Get.find();

    final index1 = files.indexWhere((e) => e.id == ids.first);
    final index2 = files.indexWhere((e) => e.id == ids.last);

    if (index1 < 0 || index2 < 0) return;

    final begin = index1 < index2
        ? index1
        : index2;
    final end = index1 < index2
        ? index2
        : index1;

    final lastId = ids.last;
    ids.remove(lastId);

    for (int i = begin; i < end; i++) {
      ids.add(files[i].id);
    }

    ids.add(lastId);
  }
}