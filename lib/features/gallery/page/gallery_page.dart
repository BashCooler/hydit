import 'package:flutter/material.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/widgets/common/swipeable.dart';
import 'package:hydit/features/search/getx/query.dart';
import 'package:hydit/features/viewer/bindings.dart';
import 'package:hydit/features/viewer/page/viewer_page.dart';

import '../bindings.dart';
import '../getx/loader.dart';
import '../getx/gallery.dart';
import '../getx/selection.dart';
import '../widget/widgets.dart';


class Gallery extends StatelessWidget {
  final GalleryBindings bindings;
  final bool editor;
  final bool swipeGesture;
  final Widget? trailing;

  const Gallery({
    super.key,
    required this.bindings,
    this.swipeGesture = true,
    required this.editor,
    this.trailing,
  });

  String get tag => bindings.tag;

  FileStore get store => bindings.store;

  GalleryController get gallery => bindings.gallery;

  SelectionController get selection => bindings.selection;

  Loader? get loader => maybeFind(tag: tag);

  QueryController? get query => maybeFind(tag: tag);

  void onTileTap(int id, int index) {
    if (gallery.loading.value) return;

    if (selection.on) {
      selection.select(id, index);
      return;
    }

    final file = store[index];

    if (file.removing) return;

    final bindings = ViewerBindings(
      files: store,
      index: index,
      grid: gallery.grid,
    );

    to(
      () => Viewer(bindings: bindings),
      transition: .fadeIn,
      curve: Curves.easeInCubic,
      onOpen: gallery.hide,
      onClose: gallery.show,
      binding: bindings,
      arguments: {
        'editor': editor,
        'delete': editor,
      }
    );
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
