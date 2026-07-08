import 'package:get/get.dart';
import 'package:flutter/animation.dart';
import 'package:hydit/features/editor/getx/base.dart';

import 'package:hydit/utils/theme.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/viewer/getx/page.dart';
import 'package:hydit/features/search/getx/tag_search.dart';
import 'package:hydit/features/gallery/getx/gallery.dart';
import 'package:hydit/widgets/swipeable.dart';

import 'getx/batch.dart';
import 'page/editor.dart';
import 'getx/single.dart';


enum Mode { paged, batch }


/// Builds an [Editor] page.
///
/// First initialize the [EditorPage], then call [paged] or [batch] to
/// select the page type. Finish with a [push] to push a newly created
/// [Editor] page.
///
/// You can also provide an [onClose] similar to awaiting
/// the result then performing an action with a regular route.
///
/// You can also [passTag]. You should only do this if you want to connect
/// pages together. For example, if you pass the tag of the `Viewer` page,
/// then `Viewer` and [Editor] will use the same [PageGetxController],
/// because it was already instantiated in `Viewer` and [Get] will not
/// create the controller again.
class EditorPage {
  final FileStore files;
  final String? service;

  String? tag;
  int? index;
  GalleryController? gallery;
  List<int>? ids;
  Mode mode = Mode.paged;
  VoidCallback? _onClose;

  EditorPage(this.files, [this.service]);

  EditorPage paged(int index, [GalleryController? gallery]) {
    this.index = index;
    this.gallery = gallery;
    mode = .paged;

    return this;
  }

  EditorPage batch(GalleryController gallery, List<int> ids) {
    this.gallery = gallery;
    this.ids = ids;
    mode = .batch;

    return this;
  }

  EditorPage onClose(VoidCallback callback) {
    _onClose = callback;

    return this;
  }

  EditorPage passTag(String tag) {
    this.tag = tag;

    return this;
  }

  void push() {
    tag ??= 'Editor-${DateTime.now().microsecondsSinceEpoch}';

    Get.to(() => SwipeablePage(child: Editor(tag: tag!)),
      transition: .rightToLeft,
      duration: transition,
      curve: Curves.easeInOutCubic,
      opaque: false,
      binding: EditorBindings(this),
    )?.then((result) {
      _onClose?.call();
    });
  }
}


class EditorBindings extends Bindings {
  final EditorPage page;

  EditorBindings(this.page);

  @override
  void dependencies() {

    Get.put(page.files.copy(), tag: page.tag);
    Get.put(TagSearchController(), tag: page.tag);

    switch (page.mode) {
      case .paged:
        Get.put<TagManager>(
          SingleTagManager(
            page.files[page.index!],
            service: page.service,
          ),
          tag: page.tag,
        );
      case .batch:
        Get.put<TagManager>(
          BatchTagManager(page.files.rx),
          tag: page.tag,
        );
    }
  }
}
