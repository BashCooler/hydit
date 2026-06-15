import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/search/widget/sorting.dart';
import 'package:hydit/features/viewer/getx/bindings.dart';

import '../getx/gallery.dart';
import '../getx/bindings.dart';
import '../getx/selection.dart';
import '../widget/app_bar.dart';
import '../widget/floating.dart';
import '../widget/gridview.dart';
import '../widget/select.dart';


class Gallery extends StatelessWidget {
  final String tag;
  final Mode mode;

  const Gallery({super.key, required this.tag, this.mode = .full});

  bool get full => mode == .full;

  @override
  Widget build(BuildContext context) {
    final FileStore files = Get.find(tag: tag);
    final GalleryController gallery = Get.find(tag: tag);
    final SelectionController selection = Get.find(tag: tag);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: GalleryAppBar(
        tag: tag,
        actions: [
          if (mode == .full && selection.off) const SortPopUp(),
        ],
      ),
      body: Stack(
        alignment: .bottomRight,
        children: [
          GalleryGridView(
            tag: tag,
            allowRefresh: (_) => full && selection.off,
            onTap: (id, index) {
              if (gallery.refreshing.value) return;
              switch (selection.on) {
                case true:
                  selection.toggle(id);
                case false:
                  ViewerPage(files, index, gallery)
                      .editor(full)
                      .beforePush(gallery.hide)
                      .onClose(gallery.show)
                      .push();
              }
            },
            onLongPress: full ? selection.selectTile : null,
          ),
          if (full) FloatingActions(tag: tag),
        ],
      ),
      bottomNavigationBar: selection.on
          ? SelectActions(tag: tag)
          : null,
    );
  }
}
