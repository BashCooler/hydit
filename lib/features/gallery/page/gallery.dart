import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/core/states/files.dart';
import 'package:hydit/features/search/getx/query.dart';
import 'package:hydit/features/viewer/getx/bindings.dart';
import 'package:hydit/features/search/widget/sorting.dart';

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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (mode == .preview) {
          Get.back();
          return;
        }

        if (selection.on) {
          selection.clear();
          gallery..unlockActions()..showActions();
          return;
        }

        final alert = AlertDialog(
          actionsAlignment: .center,
          icon: const Icon(Icons.close),
          title: 'Close application?'.n,
          actions: [
            n.Button('No'.n)
              ..onPressed = () => Get.back(),
            n.Button('Yes'.n)
              ..onPressed = () => SystemNavigator.pop(),
          ],
        );

        n.showDialog(context: context, builder: (context) => alert);
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
                      toViewer(
                        index: index,
                        files: files,
                        gallery: gallery,
                        showFloatingActionButton: full,
                      );
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
