import 'package:get/get.dart';
import 'package:hydit/reactive/cache.dart';

import 'package:hydit/reactive/file.dart';


class FileStore extends GetxController {
  /// Ids of all files in this store, loaded and not.
  final ids = <int>[].obs;

  /// Loaded file ids.
  final loaded = <int>[].obs;

  /// The number of loaded files.
  int get length => loaded.length;

  FileCache get cache => Get.find();

  HydrusFile operator [](int index) => cache[ids[index]]!;

  /// Loaded files from this store.
  Iterable<HydrusFile> get files => loaded.map((id) => cache[id]!);

  late final Worker worker;

  @override
  void onInit() {
    worker = ever(cache.deleted, remove);
    super.onInit();
  }

  @override
  void onClose() {
    worker.dispose();
    super.onClose();
  }

  /// Add files to this store and the [FileCache].
  void commit(Iterable<HydrusFile> files, {
    bool clear = false,
  }) {
    final ids = files.ids;

    final map = Map<int, HydrusFile>.fromIterable(
      files,
      key: (file) => file.id,
    );

    if (clear) {
      cache.assignAll(map);
      loaded.assignAll(ids);
    } else {
      cache.addAll(map);
      loaded.addAll(ids);
    }
  }

  void remove(Iterable<int> ids) {
    this.ids.removeWhere(ids.contains);

    loaded.removeWhere(ids.contains);
  }
}
