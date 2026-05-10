import 'dart:developer';

import 'package:get/get.dart';
import 'package:hydrus_flutter/core/domain/file_repo.dart';


class SelectionController extends GetxController {
  final selectedIds = <int>{}.obs;

  bool get rangeSelected => selectedIds.length == 2;

  bool get on => selectedIds.isNotEmpty;

  void toggle(int id) {
    switch (selectedIds.contains(id)) {
      case true:
        selectedIds.remove(id);
      case false:
        selectedIds.add(id);
    }
    log(selectedIds.toString());
  }

  void clear() => selectedIds.clear();

  bool isSelected(int id) => selectedIds.contains(id);

  void selectRange() {
    if (!rangeSelected) return;
    final FileRepo files = Get.find();

    final index1 = files.indexWhere((e) => e.id == selectedIds.first);
    final index2 = files.indexWhere((e) => e.id == selectedIds.last);

    if (index1 < 0 || index2 < 0) return;

    final begin = index1 < index2
        ? index1
        : index2;
    final end = index1 < index2
        ? index2
        : index1;

    final lastId = selectedIds.last;
    selectedIds.remove(lastId);

    for (int i = begin; i < end; i++) {
      selectedIds.add(files[i].id);
    }

    selectedIds.add(lastId);
  }
}