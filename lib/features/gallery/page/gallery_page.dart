import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/features/search/bindings.dart';
import 'package:hydit/features/search/getx/query.dart';

import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/search/widget/sorting.dart';
import 'package:hydit/features/viewer/bindings.dart';

import '../getx/gallery.dart';
import '../getx/selection.dart';
import '../widget/widgets.dart';


class Gallery extends StatelessWidget {
  final String tag;
  final bool search;
  final bool editor;

  const Gallery({
    super.key,
    required this.tag,
    required this.search,
    required this.editor,
  });

  @override
  Widget build(BuildContext context) {
    final FileStore files = Get.find(tag: tag);
    final GalleryController gallery = Get.find(tag: tag);
    final SelectionController selection = Get.find(tag: tag);

    return Obx(() {
      return Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: GalleryAppBar(
          tag: tag,
          query: search ? Get.find<QueryController>() : null,
          actions: [
            if (search && selection.off) const SortPopUp(),
          ],
        ),
        body: Stack(
          alignment: .bottomRight,
          children: [
            GalleryGridView(
              tag: tag,
              allowRefresh: (_) => search && selection.off,
              onRefresh: () async {
                if (search) Get.find<QueryController>().searchForFiles();
              },
              onTap: (id, index) {
                if (gallery.refreshing.value) return;
                switch (selection.on) {
                  case true:
                    selection.toggle(id);
                  case false:
                    ViewerPage(files, index, gallery)
                        .editor(editor)
                        .beforePush(gallery.hide)
                        .onClose(gallery.show)
                        .push();
                }
              },
              onLongPress: editor ? selection.selectTile : null,
            ),
          ],
        ),
        floatingActionButton: search && selection.off
            ? AcrylicFAB(onTap: SearchPage(tag).push)
            : null,
        bottomNavigationBar: HidableBottomBar(
          tag: tag,
          show: selection.on,
          child: SelectActions(tag: tag),
        ),
      );
    });
  }
}
