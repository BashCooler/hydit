import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:snapping_sheet_2/snapping_sheet.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:preload_page_view/preload_page_view.dart';

import 'package:hydrus_flutter/core/ui/common.dart';
import 'package:hydrus_flutter/core/domain/file_repo.dart';
import 'package:hydrus_flutter/features/gallery/getx/gallery.dart';

import '../getx/page.dart';
import '../widget/views.dart';
import '../widget/tag_sheet.dart';


class Viewer extends StatelessWidget {
  final int index;
  final String tag;

  const Viewer(this.index, {super.key, required this.tag});

  void showSearchBar(bool didPop, dynamic result) async {
    Future.delayed(Duration(milliseconds: 250), () {
      final GalleryController gallery = Get.find();
      gallery..showActions()..showBadges();
    });
  }

  @override
  Widget build(BuildContext context) {
    final FileRepo files = Get.find(tag: tag);
    final PageGetxController page = Get.find(tag: tag);

    return PopScope(
      onPopInvokedWithResult: showSearchBar,
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
          return TagSheet(
            tags: files[page.i].all,
            tag: tag,
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
    final FileRepo files = Get.find();
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
            return DismissibleFile(index, tag: tag);
          },
        );
      }),
    );
  }
}


class DismissibleFile extends StatelessWidget {
  final int index;
  final String tag;

  const DismissibleFile(this.index, {super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final PageGetxController page = Get.find(tag: tag);

    return Obx(() {
      return DismissiblePage(
        disabled: page.blockDismiss,
        backgroundColor: Theme
            .of(context)
            .scaffoldBackgroundColor,
        onDismissed: Navigator
            .of(context)
            .pop,
        direction: .vertical,
        interactionMode: .gesture,
        minScale: 0,
        builder: (context, scrollController) {
          return ViewFile(index, tag: tag);
        },
      );
    });
  }
}



class BottomActions extends StatelessWidget {
  final String tag;

  const BottomActions({super.key, required this.tag});

  void openSheet() {
    final SnappingSheetController sheet = Get.find(tag: tag);
    sheet.snapToPosition(.factor(positionFactor: 0.5));
  }

  @override
  Widget build(BuildContext context) {
    final PageGetxController page = Get.find(tag: tag);
    final FileRepo files = Get.find();

    return BottomAppBar(
      color: Get.theme.scaffoldBackgroundColor.withAlpha(90),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        spacing: 10.0,
        children: [
          IconButton(
            tooltip: 'Previous page',
            color: Colors.white,
            onPressed: () => page.$.previousPage(
              duration: const Duration(milliseconds: 150),
              curve: Curves.decelerate,
            ),
            icon: const Icon(Icons.keyboard_arrow_left),
          ),
          Obx(() {
            return n.Button('${files[page.i].length} tags'.n)
              ..tooltip = 'Show tags'
              ..foregroundColor = Colors.white
              ..overlayColor = Colors.white.withAlpha(32)
              ..fontSize = 16
              ..fontWeight = .w500
              ..shadows = [Shadow(blurRadius: 24)]
              ..onPressed = openSheet
              ..expanded;
          }),
          IconButton(
            tooltip: 'Next page',
            color: Colors.white,
            onPressed: () => page.$.nextPage(
              duration: const Duration(milliseconds: 150),
              curve: Curves.decelerate,
            ),
            icon: const Icon(Icons.keyboard_arrow_right),
          ),
        ],
      ),
    );
  }
}
