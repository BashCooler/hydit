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
  final String? service;
  final VoidCallback? beforePush;
  final VoidCallback? onClose;
  final List<int>? ids;
  final PageGetxController? page;

  EditorPage.paged({
    required this.page,
    this.service,
    this.beforePush,
    this.onClose,
  })
      : tag = 'Editor'.unique(),
        ids = null {
    push();
  }

  EditorPage.batch({
    required this.ids,
    this.service,
    this.beforePush,
    this.onClose,
  })
      : tag = 'Editor'.unique(),
        page = null {
    push();
  }

  void push() {
    Get.to(
      () => SwipeablePage(child: Editor(tag: tag)),
      curve: Curves.easeInOutCubic,
      opaque: false,
      binding: page != null
          ? PagedEditorBindings(tag: tag, page: page!, service: service)
          : BatchEditorBindings(tag: tag, ids: ids!),
    )?.then((result) {
      onClose?.call();
    });
  }
}


class PagedEditorBindings extends Bindings {
  final String tag;
  final String? service;
  final PageGetxController page;

  PagedEditorBindings({
    required this.tag,
    required this.page,
    this.service,
  });

  @override
  void dependencies() {
    Get.put(
      TagSearchController(),
      tag: tag,
    );

    Get.put<TagManager>(
      PagedTagManager(page: page, service: service),
      tag: tag,
    );
  }
}


class BatchEditorBindings extends Bindings {
  final String tag;
  final List<int> ids;

  BatchEditorBindings({required this.tag, required this.ids});

  @override
  void dependencies() {
    Get.put(
      TagSearchController(),
      tag: tag,
    );

    final store = FileStore(ids);

    Get.put<TagManager>(
      BatchTagManager(store),
      tag: tag,
    );
  }
}
