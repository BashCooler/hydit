import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/services/loader.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/widgets/common/swipeable.dart';
import 'package:hydit/features/search/getx/query.dart';
import 'package:hydit/features/viewer/bindings.dart';
import 'package:hydit/features/viewer/page/viewer.dart';

import '../getx/gallery.dart';
import '../getx/selection.dart';
import '../widget/widgets.dart';


class Gallery extends StatelessWidget {
  final String tag;
  final bool editor;
  final bool swipeGesture;
  final Widget? trailing;

  const Gallery({
    super.key,
    required this.tag,
    this.swipeGesture = true,
    required this.editor,
    this.trailing,
  });

  FileStore get files => Get.find(tag: tag);
  GalleryController get gallery => Get.find(tag: tag);
  SelectionController get selection => Get.find(tag: tag);

  Loader? get loader => maybeFind(tag: tag);
  QueryController? get query => maybeFind(tag: tag);

  Future<void> onTileTap(int id, int index) async {
    if (gallery.loading.value) return;

    if (selection.on) {
      selection.select(id, index);
      return;
    }

    final file = files[index];

    if (file.removing) return;

    final tag = 'Viewer'.unique();

    gallery.hide();

    await Get.to(
      () => Viewer(tag: tag),
      transition: .fadeIn,
      curve: Curves.easeInCubic,
      opaque: false,
      binding: ViewerBindings(
        tag: tag,
        files: files,
        index: index,
        grid: gallery.grid,
      ),
      arguments: {
        'editor': editor,
        'delete': editor,
      }
    );

    gallery.show();
  }

  @override
  Widget build(BuildContext context) {
    return Wrapper(
      condition: swipeGesture,
      builder: (child) => SwipeablePage(child: child),
      child: Scaffold(
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
          onTap: onTileTap,
          onLongPress: editor ? selection.select : null,
          onBuild: loader?.next,
        ),
        floatingActionButton: GalleryFAB(tag: tag),
        bottomNavigationBar: SelectionBottomBar(tag: tag),
      ),
    );
  }
}
