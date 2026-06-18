import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/features/editor/bindings.dart';
import 'package:hydit/features/search/bindings.dart';
import 'package:hydit/features/search/getx/query.dart';

import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/viewer/bindings.dart';
import 'package:hydit/utils/utils.dart';

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

  FileStore get files => Get.find(tag: tag);
  QueryController get query => Get.find(tag: tag);
  GalleryController get gallery => Get.find(tag: tag);
  SelectionController get selection => Get.find(tag: tag);

  void onTileTap(int id, int index) {
    if (gallery.loading.value) return;

    if (selection.on) {
      selection.selectTile(id, index);
      return;
    }

    ViewerPage(files, index, gallery)
        .editor(editor)
        .beforePush(gallery.hide)
        .onClose(gallery.show.delayed(transition))
        .push();
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: GalleryAppBar(
        tag: tag,
        search: search,
        onTap: gallery.scrollUp,
      ),
      body: Stack(
        alignment: .bottomRight,
        children: [
          GalleryGridView(
            tag: tag,
            allowRefresh: (_) => search && selection.off,
            onRefresh: query.search,
            selected: selection.isSelected,
            onTap: onTileTap,
            onLongPress: editor ? selection.selectTile : null,
          ),
        ],
      ),
      floatingActionButton: search && selection.off
          ? AcrylicFAB(onTap: SearchPage(query: query).push)
          : null,
      bottomNavigationBar: SelectionBottomBar(
        tag: tag,
        onEdit: (index) => EditorPage(files)
            .paged(index, gallery)
            .onClose(selection.clear)
            .push(),
        onBatchEdit: (files, ids) => EditorPage(files)
            .batch(gallery, ids)
            .onClose(selection.clear)
            .push(),
      ),
    );
  });
}
