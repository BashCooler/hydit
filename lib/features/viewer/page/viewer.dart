import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:preload_page_view/preload_page_view.dart';

import 'package:hydit/core/state/file.dart';
import 'package:hydit/core/state/files.dart';
import 'package:hydit/features/editor/getx/bindings.dart';
import 'package:hydit/features/gallery/getx/gallery.dart';

import '../getx/page.dart';
import '../widget/bottom_bar.dart';
import '../widget/physics.dart';
import '../widget/views.dart';
import '../widget/tag_sheet.dart';


class Viewer extends StatelessWidget {
  final int index;
  final String tag;
  final GalleryController? gallery;
  final bool showFloatingActionButton;

  const Viewer({
    super.key,
    required this.index,
    required this.tag,
    required this.gallery,
    this.showFloatingActionButton = true,
  });

  static const message =
      'It is required for HydrusFile to be loaded '
      'before building a Viewer widget';

  @override
  Widget build(BuildContext context) {
    final FileStore files = Get.find(tag: tag);
    final PageGetxController page = Get.find(tag: tag);

    assert(files[page.i].loaded, message);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final SnappingSheetController sheet = Get.find(tag: tag);
        if (page.sheetProgress.value > 0.5) {
          sheet.snapToPosition(SnappingPosition.factor(positionFactor: 0));
          return;
        }

        Get.back();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: Get.mediaQuery.viewInsets.top,
          backgroundColor: Get.theme.scaffoldBackgroundColor.withAlpha(90),
        ),
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: Obx(() {
          final file = files[page.i];
          return TagSheet(
            tags: file.meta!.all.toList(),
            tag: tag,
            gallery: gallery,
            onFloatingActionButtonTap: showFloatingActionButton
                ? () => toEditorPaged(tag, page.i, files, gallery)
                : null,
            child: Pages(tag: tag),
          );
        }),
        bottomNavigationBar: BottomActions(tag: tag),
      ),
    );
  }
}

class Pages extends StatelessWidget {
  final String tag;

  const Pages({super.key, required this.tag});

  static const scroll = SnappyPageScrollPhysics();
  static const noScroll = NeverScrollableScrollPhysics();

  @override
  Widget build(BuildContext context) {
    final FileStore files = Get.find(tag: tag);
    final PageGetxController page = Get.find(tag: tag);

    return Listener(
      onPointerUp: page.registerPointer,
      onPointerDown: page.registerPointer,
      child: Obx(() {
        return PreloadPageView.builder(
          onPageChanged: page.onPageChanged,
          physics: page.noScroll ? noScroll : scroll,
          controller: page.controller,
          itemCount: files.length,
          preloadPagesCount: 3,
          itemBuilder: (_, index) {
            return DismissibleFile(
              tag: tag,
              index: index,
              file: files[index],
            );
          },
        );
      }),
    );
  }
}


class DismissibleFile extends StatelessWidget {
  final int index;
  final HydrusFile file;
  final String tag;

  const DismissibleFile({
    super.key,
    required this.index,
    required this.tag,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    final PageGetxController page = Get.find(tag: tag);

    return Obx(() {
      return DismissiblePage(
        disabled: page.blockDismiss,
        backgroundColor: Theme
            .of(context)
            .scaffoldBackgroundColor,
        onDismissed: Get.back,
        direction: .vertical,
        interactionMode: .gesture,
        minScale: 0,
        builder: (context, scrollController) {
          return ViewFile(tag: tag, index: index, file: file);
        },
      );
    });
  }
}
