import 'package:get/get.dart';

import 'package:hydit/features/gallery/getx/loader.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/search/getx/query.dart';

import 'getx/gallery.dart';
import 'getx/selection.dart';


class GalleryBindings.fileStore({
  required final String tag,
  required final bool search,
  required final FileStore store,
}) extends Bindings {
  //
  new({
    required String tag,
    required bool search,
    List<int> ids = const [],
  }) : this.fileStore(
    tag: tag,
    search: search,
    store: FileStore(ids),
  );

  final gallery = GalleryController();

  late final selection = SelectionController(
    tag: tag,
    store: store,
    enabled: () => !gallery.loading.value,
  );

  @override
  void dependencies() {
    Get.put(gallery, tag: tag);
    Get.lazyPut(() => selection, tag: tag);
    Get.put(store, tag: tag);

    if (search) {
      final loader = Loader(store: store);

      Get.put(loader, tag: tag);

      final query = QueryController(
        onResults: loader.init,
        beforeSearch: () => gallery.loading.value = true,
        afterSearch: () => gallery.loading.value = false,
      );

      Get.put(query, tag: tag);
    }
  }
}
