import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart' hide NumDurationExtensions;
import 'package:flutter_inner_drawer/inner_drawer.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/services/loader.dart';
import 'package:hydit/widgets/acrylic.dart' as a;
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/search/bindings.dart';
import 'package:hydit/features/search/getx/query.dart';
import 'package:hydit/features/viewer/bindings.dart';

import '../getx/gallery.dart';
import '../getx/selection.dart';
import '../widget/widgets.dart';


class Gallery extends StatelessWidget {
  final String tag;
  final bool search;
  final bool editor;
  final GlobalKey<InnerDrawerState>? state;

  const Gallery({
    super.key,
    required this.tag,
    required this.search,
    required this.editor,
    this.state,
  });

  Loader get loader => Get.find(tag: tag);
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
        state: state,
        onTap: gallery.scrollUp,
      ),
      body: Stack(
        alignment: .bottomRight,
        children: [
          GalleryGridView(
            tag: tag,
            allowRefresh: (_) => search && selection.off,
            onRefresh: search ? query.search : null,
            selected: selection.isSelected,
            onTap: onTileTap,
            onLongPress: editor ? selection.selectTile : null,
            onBuild: search ? loader.next : null,
          ),
        ],
      ),
      floatingActionButton: selection.off && search
          ? GalleryFAB(tag: tag)
          : null,
      bottomNavigationBar: SelectionBottomBar(tag: tag),
    );
  });
}


class GalleryFAB extends StatelessWidget {
  final String tag;

  GalleryFAB({super.key, required this.tag});

  Loader get loader => Get.find(tag: tag);

  final failed = false.obs;

  @override
  Widget build(BuildContext context) => Obx(() {

    final acrylic = a.AcrylicFAB(onTap: failed.toggle);
    final error = FloatingActionButton(onPressed: failed.toggle);

    final current = failed.value ? error : acrylic;
    final next = failed.value ? acrylic : error;

    return current
        .animate(key: ValueKey(failed.value))
        .scaleXY(begin: 1, end: 0)
        .swap(builder: (context, child) => next.animate().scaleXY());
  });
}

