import 'package:get/get.dart';

import 'package:hydit/reactive/file_store.dart';
import 'gallery.dart';


class SelectionController extends GetxController {
  final ids = <int>{}.obs;

  final GalleryController gallery;
  final FileStore files;

  SelectionController(this.files, this.gallery);

  bool get rangeSelected => ids.length == 2;

  bool get on => ids.isNotEmpty;
  bool get off => ids.isEmpty;

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

  void selectTile(int id) {
    if (gallery.refreshing.value) return;
    toggle(id);
  }
}