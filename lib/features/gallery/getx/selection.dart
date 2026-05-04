import 'package:get/get.dart';


class SelectionController extends GetxController {
  final selectedIds = <int>{}.obs;

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
}