import 'package:get/get.dart';
import 'package:hydrus_flutter/core/domain/di/images.dart';


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
  }

  void clear() => selectedIds.clear();

  bool isSelected(int id) => selectedIds.contains(id);

  void selectRange() {
    if (!rangeSelected) return;
    final Images images = Get.find();

    final index1 = images.indexWhere((e) => e.id == selectedIds.first);
    final index2 = images.indexWhere((e) => e.id == selectedIds.last);

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