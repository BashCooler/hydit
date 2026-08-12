import 'package:get/get.dart';

import 'package:hydit/services/loader.dart';
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

    Get.put(GalleryController(), tag: tag);

    Get.lazyPut(
      () => SelectionController(tag: tag),
      tag: tag,
    );

    Get.put(FileStore(ids), tag: tag);

    if (search) {
      Get.put(Loader(tag: tag), tag: tag);
      Get.put(QueryController(tag: tag), tag: tag);
    }
  }
}
