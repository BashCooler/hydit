import 'package:get/get.dart';

import 'package:hydit/features/gallery/getx/loader.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/search/getx/query.dart';

import 'getx/gallery.dart';
import 'getx/selection.dart';


class GalleryBindings extends Bindings {
  final String tag;
  final bool search;
  final List<int> ids;

  GalleryBindings({
    required this.tag,
    required this.search,
    this.ids = const [],
  });

  @override
  void dependencies() {
    final gallery = GalleryController();

    Get.put(gallery, tag: tag);

    Get.lazyPut(
      () => SelectionController(tag: tag),
      tag: tag,
    );

    Get.put(FileStore(ids), tag: tag);

    if (search) {
      final loader = Loader(tag: tag);

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
