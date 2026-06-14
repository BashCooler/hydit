import 'package:get/get.dart';

import 'package:hydit/reactive/file_store.dart';
import 'gallery.dart';


class SelectionController extends GetxController {
  final ids = <int>{}.obs;

  final GalleryController gallery;
  final FileStore fileRepo;

  SelectionController({required this.gallery, required this.fileRepo});

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
    if (on) {
      gallery..unlockActions()..showActions();
    }
  }

  void clear() {
    ids.clear();
    gallery..unlockActions()..showActions();
  }

  bool isSelected(int id) => ids.contains(id);

  void selectRange() {
    if (!rangeSelected) return;

    final index1 = fileRepo.indexWhere((e) => e.id == ids.first);
    final index2 = fileRepo.indexWhere((e) => e.id == ids.last);

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
      ids.add(fileRepo[i].id);
    }

    ids.add(lastId);
  }

  void selectTile(int id) {
    if (gallery.refreshing.value) return;
    toggle(id);
    if (on) gallery..hideActions()..lockActions();
  }
}