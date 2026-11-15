import 'package:get/get.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/search/getx/query.dart';
import 'package:hydit/features/gallery/getx/loader.dart';

import 'getx/gallery.dart';
import 'getx/selection.dart';


class GallerySession {
  final loading = false.obs;

  final store = FileStore([]);

  late final loader = Loader(store: store);

  late final query = QueryController(session: this);

  late final bindings = GalleryBindings.session(this);
}


class GalleryBindings extends Bindings {
  //
  final GallerySession? session;

  final FileStore store;

  GalleryBindings({required List<int> ids})
    : session = null,
      store = FileStore(ids);

  GalleryBindings.session(GallerySession session)
    : session = session,
      store = session.store;

  final tag = 'Gallery'.unique();

  final gallery = GalleryController();

  late final selection = SelectionController(
    store: store,
    enabled: () => session?.loading.value.not() ?? false,
  );

  @override
  void dependencies() {
    Get.put(gallery, tag: tag);
    Get.lazyPut(() => selection, tag: tag);
    Get.put(store, tag: tag);
  }
}
