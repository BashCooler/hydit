import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/features/editor/bindings.dart';
import 'package:hydit/features/search/bindings.dart';
import 'package:hydit/features/search/getx/query.dart';

import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/search/widget/sorting.dart';
import 'package:hydit/features/viewer/bindings.dart';
import 'package:hydit/utils/theme.dart';

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
    final files = Get
        .find<FileStore>(tag: tag);
    final query = Get
        .find<QueryController>(tag: tag);
    final gallery = Get
        .find<GalleryController>(tag: tag);
    final selection = Get
        .find<SelectionController>(tag: tag);

    return Obx(() {
      return Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: GalleryAppBar(
          tag: tag,
          query: search ? query : null,
          actions: [
            if (search && selection.off) SortPopUp(query: query),
          ],
        ),
        body: Stack(
          alignment: .bottomRight,
          children: [
            GalleryGridView(
              tag: tag,
              allowRefresh: (_) => search && selection.off,
              onRefresh: () async {
                if (search) query.searchForFiles();
              },
              selected: (id) => selection.isSelected(id),
              onTap: (id, index) {
                switch (selection.on) {
                  case true:
                    selection.selectTile(id, index);
                  case false:
                    ViewerPage(files, index, gallery)
                        .editor(editor)
                        .beforePush(gallery.hide)
                        .onClose(gallery.show.delayed(AppTheme.duration))
                        .push();
                }
              },
              onLongPress: editor ? selection.selectTile : null,
            ),
          ],
        ),
        floatingActionButton: search && selection.off
            ? AcrylicFAB(onTap: SearchPage(query: query).push)
            : null,
        bottomNavigationBar: SelectionBottomBar(
          tag: tag,
          show: selection.on,
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
}
