import 'package:get/get.dart';
import 'package:flutter/animation.dart';
import 'package:hydit/reactive/file_store.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/widgets/common/swipeable.dart';
import 'package:hydit/features/viewer/getx/page.dart';
import 'package:hydit/features/search/getx/tag_search.dart';

import 'getx/base.dart';
import 'getx/batch.dart';
import 'getx/single.dart';
import 'page/editor.dart';


/// Builds an [Editor] page.
///
/// First initialize the [EditorPage], then call [paged] or [batch] to
/// select the page type. Finish with a [push] to push a newly created
/// [Editor] page.
///
/// You can also provide an [onClose] similar to awaiting
/// the result then performing an action with a regular route.
class EditorPage {
  final String tag;

  String? selectedService;

  List<int>? ids;

  PageGetxController? page;

  VoidCallback? onCloseCallback;

  EditorPage() : tag = 'Editor'.unique();

  EditorPage paged(PageGetxController page) {
    this.page = page;

    return this;
  }

  EditorPage batch(Iterable<int> ids) {
    this.ids = ids.toList();

    return this;
  }

  EditorPage onClose(VoidCallback callback) {
    onCloseCallback = callback;

    return this;
  }

  EditorPage service(String name) {
    selectedService = name;

    return this;
  }

  void push() {
    Get.to(
      () => SwipeablePage(child: Editor(tag: tag)),
      curve: Curves.easeInOutCubic,
      opaque: false,
      binding: EditorBindings(this),
    )?.then((result) {
      onCloseCallback?.call();
    });
  }
}


class EditorBindings extends Bindings {
  final EditorPage page;

  EditorBindings(this.page);

  @override
  void dependencies() {

    Get.put(TagSearchController(), tag: page.tag);

    switch (page.page) {

      case null:
        final store = FileStore(page.ids!);

        Get.put<TagManager>(
          BatchTagManager(store),
          tag: page.tag,
        );

      case _:
        Get.put<TagManager>(
          PagedTagManager(page: page.page!, service: page.selectedService),
          tag: page.tag,
        );
    }
  }
}
