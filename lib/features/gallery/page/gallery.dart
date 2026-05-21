import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/core/ui/common.dart';
import 'package:hydit/core/domain/file_repo.dart';
import 'package:hydit/features/search/page/search.dart';
import 'package:hydit/features/search/widget/sorting.dart';
import 'package:hydit/features/viewer/getx/bindings.dart';
import 'package:hydit/features/editor/getx/bindings.dart';
import 'package:hydit/features/settings/ui/page/settings.dart';

import '../getx/bindings.dart';
import '../getx/gallery.dart';
import '../getx/selection.dart';
import '../widget/gridview.dart';


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

  @override
  Widget build(BuildContext context) {
    final FileRepo files = Get.find(tag: tag);
    final GalleryController gallery = Get.find(tag: tag);
    final SelectionController selection = Get.find(tag: tag);

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
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(decoration: buildBoxDecoration()),
            title: GestureDetector(
              onTap: () => scrollUp(gallery),
              child: '${files.length} files'.n
                ..color = Colors.white
                ..bodyLarge
                ..shadows = const [
                  Shadow(blurRadius: 16),
                ],
            ),
            actions: const [
              SortPopUp(),
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
              full ? FloatingActions(tag: tag) : const SizedBox.shrink(),
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


class FloatingActions extends StatelessWidget {
  final String tag;

  const FloatingActions({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final GalleryController gallery = Get.find(tag: tag);
    return Obx(() {
      return AnimatedContainer(
        curve: Curves.easeOutCubic,
        duration: const Duration(milliseconds: 350),
        height: gallery.actionsVisible
            ? MediaQuery.of(context).viewPadding.bottom * 2
            : 0,
        child: n.Wrap([
          n.Row([
            FilledIconButton(
              onPressed: () {
                Get.to(() => const SettingsPage(), transition: .downToUp);
              },
              icon: const Icon(Icons.settings),
            ),
            FilledIconButton(
              onPressed: () {
                gallery.hideActions();
                Get.to(() => Search(tag: tag), transition: .downToUp);
              },
              icon: const Icon(Icons.search),
            ),
          ])
            ..mainAxisAlignment = .spaceBetween
            ..n.padding = .only(left: 15.0, right: 15.0, bottom: 15.0),
        ]),
      );
    });
  }
}


class SelectActions extends StatelessWidget {
  final String tag;

  const SelectActions({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final FileRepo files = Get.find(tag: tag);
    final SelectionController selection = Get.find(tag: tag);
    final GalleryController gallery = Get.find(tag: tag);

    return BottomAppBar(
      color: Get.theme.scaffoldBackgroundColor.withAlpha(90),
      child: n.Row([
        Obx(() {
          return '${selection.ids.length} selected'.n
            ..expanded
            ..color = Colors.white
            ..fontSize = 16
            ..fontWeight = .w500
            ..shadows = [Shadow(blurRadius: 24)]
            ..textAlign = .center;
        }),
        n.Row([
          IconButton(
            tooltip: 'Edit tags',
            icon: const Icon(Icons.edit),
            color: Colors.white,
            onPressed: () async {
              final tag = 'Editor-${DateTime.now().microsecondsSinceEpoch}';
              switch (selection.ids.length) {
                case 1:
                  final id = selection.ids.first;
                  final index = files.indexWhere((f) => f.id == id);
                  await toEditorPaged(tag, index, files, gallery);
                  selection.clear();
                case _:
                  final fileRepo = FileRepo.pickFrom(files, selection.ids.toList());
                  await toEditorBatch(tag, fileRepo, gallery, selection.ids.toList());
                  selection.clear();
              }
            },
          ),
          Obx(() {
            switch (selection.rangeSelected) {
              case true:
                return IconButton(
                  tooltip: 'Select range',
                  icon: const Icon(Icons.select_all),
                  color: Colors.white,
                  onPressed: selection.selectRange,
                );
              case false:
                return const SizedBox.shrink();
            }
          }),
        ])
          ..gap = 10
          ..padding = .only(right: 10),
      ])
        ..mainAxisAlignment = .spaceBetween,
    );
  }
}
