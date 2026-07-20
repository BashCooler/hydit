import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/services/loader.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/viewer/bindings.dart';
import 'package:hydit/features/search/getx/query.dart';

import '../getx/gallery.dart';
import '../getx/selection.dart';
import '../widget/widgets.dart';


class Gallery extends StatelessWidget {
  final String tag;
  final bool editor;
  final Widget? trailing;

  const Gallery({
    super.key,
    required this.tag,
    required this.editor,
    this.trailing,
  });

  FileStore get files => Get.find(tag: tag);
  GalleryController get gallery => Get.find(tag: tag);
  SelectionController get selection => Get.find(tag: tag);

  Loader? get loader => maybeFind(tag: tag);
  QueryController? get query => maybeFind(tag: tag);

  void onTileTap(int id, int index) {
    if (gallery.loading.value) return;

    if (selection.on) {
      selection.select(id, index);
      return;
    }

    ViewerPage(files, index, gallery)
        .editor(editor)
        .beforePush(gallery.hide)
        .onClose(gallery.show)
        .push();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: GalleryAppBar(
        tag: tag,
        trailing: trailing,
        onTap: gallery.scrollUp,
      ),
      body: GalleryGridView(
        tag: tag,
        allowRefresh: (_) => selection.off,
        onRefresh: query?.search,
        selected: selection.isSelected,
        onTap: onTileTap,
        onLongPress: editor ? selection.select : null,
        onBuild: loader?.next,
      ),
      floatingActionButton: GalleryFAB(tag: tag),
      bottomNavigationBar: SelectionBottomBar(tag: tag),
    );
  }
}
