import 'package:get/get.dart';
import 'package:hydrus_flutter/core/domain/di/images.dart';


class SelectionController extends GetxController {
  final selectedIds = <int>{}.obs;

  int? beginId;
  int? endId;
  final rangeSelected = false.obs;

  bool get on => selectedIds.isNotEmpty;

  void toggle(int id) {
    switch (selectedIds.contains(id)) {
      case true:
        selectedIds.remove(id);
        if (selectedIds.length < 2) rangeSelected.value = false;
      case false:
        selectedIds.add(id);
        switch (selectedIds.length) {
          case 1:
            beginId = id;
            endId = null;
          case 2:
            endId = id;
          case _:
            beginId = null;
            endId = null;
        }
        rangeSelected.value = beginId != null && endId != null;
    }
  }

  void clear() => selectedIds.clear();

  bool isSelected(int id) => selectedIds.contains(id);

  void selectRange() {
    if (!rangeSelected.value) return;
    final Images images = Get.find();

    final index1 = images.indexWhere((e) => e.id == beginId);
    final index2 = images.indexWhere((e) => e.id == endId);

    if (index1 < 0 || index2 < 0) return;

    final begin = index1 < index2
        ? index1
        : index2;
    final end = index1 < index2
        ? index2
        : index1;

    for (int i = begin; i < end; i++) {
      selectedIds.add(images[i].id);
    }
  }
}