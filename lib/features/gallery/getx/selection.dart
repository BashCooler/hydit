import 'package:get/get.dart';
import 'package:hydit/features/editor/bindings.dart';

import 'package:hydit/reactive/file_store.dart';
import 'gallery.dart';


class SelectionController extends GetxController {
  final ids = <int>{}.obs;

  final GalleryController gallery;
  final FileStore files;

  SelectionController(this.files, this.gallery);

  bool get selectedAll => ids.length == files.length;

  bool get selectedRange {
    if (ids.length != 2) return false;  // important
    final r = range();
    return switch (r) {
      null => false,
      _ => r.$2 - r.$1 > 1,
    };
  }

  bool get on => ids.isNotEmpty;
  bool get off => ids.isEmpty;

  void clear() => ids.clear();

  bool isSelected(int id) => ids.contains(id);

  void selectTile(int id, int index) {
    if (gallery.loading.value) return;
    switch (ids.contains(id)) {
      case true:
        ids.remove(id);
      case false:
        ids.add(id);
    }
  }

  void selectRange() {
    final r = range();
    if (r == null) return;

    final lastId = ids.last;
    ids.remove(lastId);

    for (int i = r.$1; i < r.$2; i++) {
      ids.add(files[i].id);
    }

    ids.add(lastId);
  }

  void selectAll() {
    for (int i = 0; i < files.length; i++) {
      ids.add(files[i].id);
    }
  }

  (int, int)? range() {
    if (ids.length != 2) return null;

    final indices = <int>[
      ?files.indexById(ids.first),
      ?files.indexById(ids.last),
    ];

    if (indices.length < 2) return null;

    indices.sort();

    return (indices.first, indices.last);
  }

  void edit() {
    switch (ids.length) {
      case 1:
        final index = files.indexById(ids.first);
        EditorPage(files)
            .paged(index!, gallery)
            .onClose(clear)
            .push();
      case _:
        final ids = this.ids.toList();
        final files = FileStore.pickFrom(this.files, ids);
        EditorPage(files)
            .batch(gallery, ids)
            .onClose(clear)
            .push();
    }
  }
}
