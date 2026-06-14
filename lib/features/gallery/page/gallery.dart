import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/widgets/app_pop_scope.dart';
import 'package:hydit/features/search/getx/query.dart';
import 'package:hydit/features/search/widget/sorting.dart';
import 'package:hydit/features/viewer/getx/bindings.dart';

import '../getx/gallery.dart';
import '../getx/bindings.dart';
import '../getx/selection.dart';
import '../widget/floating.dart';
import '../widget/gridview.dart';
import '../widget/select.dart';


class Gallery extends StatelessWidget {
  final String tag;
  final Mode mode;

  const Gallery({super.key, required this.tag, this.mode = .full});

  bool get full => mode == .full;

  void scrollUp(GalleryController gallery) {
    gallery.scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInCubic,
    );
    gallery.showActions();
  }

  static const shadows = [ Shadow(blurRadius: 16) ];

  @override
  Widget build(BuildContext context) {
    final FileStore files = Get.find(tag: tag);
    final GalleryController gallery = Get.find(tag: tag);
    final SelectionController selection = Get.find(tag: tag);
    final QueryController query = Get.find();

    return AppPopScope(
      shouldShow: () {
        switch (selection.on) {
          case true:
            selection.clear();
            gallery..unlockActions()..showActions();
            return false;
          case false:
            return true;
        }
      },
      child: Obx(() {
        final count = '${files.length} files'.n
          ..color = Colors.white
          ..bodyLarge
          ..shadows = shadows;

        final q = '${query.values}'.replaceAll(RegExp(r'[\[\]]'), '').n
          ..color = Colors.white
          ..bodySmall
          ..shadows = shadows;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(decoration: buildBoxDecoration()),
            title: GestureDetector(
              onTap: () => scrollUp(gallery),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  count,
                  ?q.text == '' ? null : q,
                ],
              ),
            ),
            actions: [
              if (mode == .full && selection.off) const SortPopUp(),
            ],
          ),
          resizeToAvoidBottomInset: false,
          extendBodyBehindAppBar: true,
          extendBody: true,
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
      }),
    );
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Get.theme.scaffoldBackgroundColor.withAlpha(128),
          Colors.transparent,
        ],
        begin: .topCenter,
        end: .bottomCenter,
      ),
    );
  }
}
