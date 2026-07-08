import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:preload_page_view/preload_page_view.dart';

import 'package:hydit/reactive/file.dart';
import 'package:hydit/widgets/gradient.dart';

import '../getx/page.dart';
import '../widget/viewer_bar.dart';
import '../widget/physics.dart';
import '../widget/views.dart';
import '../widget/tag_sheet.dart';


class Viewer extends StatelessWidget {
  final int index;
  final String tag;
  final bool editor;
  final String? heroPrefix;

  const Viewer({
    super.key,
    required this.index,
    required this.tag,
    this.editor = true,
    this.heroPrefix,
  });

  PageGetxController get page => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (page.sheetProgress.value > 0.5) {
          page.closeSheet();
          return;
        }

        Get.back();
      },
      child: Scaffold(
        appBar: GradientAppBar(automaticallyImplyLeading: false),
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: TagSheet(
          tag: tag,
          child: Pages(tag: tag, heroPrefix: heroPrefix),
        ),
        bottomNavigationBar: ViewerBottomBar(
          tag: tag,
          editButton: editor ? EditButton(tag: tag) : null,
        ),
      ),
    );
  }
}

class Pages extends StatelessWidget {
  final String tag;
  final String? heroPrefix;

  const Pages({super.key, required this.tag, this.heroPrefix});

  static const scroll = SnappyPageScrollPhysics();
  static const noScroll = NeverScrollableScrollPhysics();

  PageGetxController get page => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: page.registerPointer,
      onPointerDown: page.registerPointer,
      child: Obx(() {
        return PreloadPageView.builder(
          onPageChanged: page.onPageChanged,
          physics: page.noScroll ? noScroll : scroll,
          controller: page.controller,
          itemCount: page.files.length,
          preloadPagesCount: 3,
          itemBuilder: (context, index) {
            return DismissibleFile(
              tag: tag,
              index: index,
              file: page.files[index],
              heroPrefix: heroPrefix,
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
  final String? heroPrefix;

  const DismissibleFile({
    super.key,
    required this.index,
    required this.tag,
    required this.file,
    this.heroPrefix,
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
        dragSensitivity: 1,
        builder: (context, scrollController) {
          return ViewFile(
            tag: tag,
            index: index,
            file: file,
            heroTag: heroPrefix != null
                ? '$heroPrefix${file.id}'
                : file.id,
          );
        },
      );
    });
  }
}


class EditButton extends StatelessWidget {
  final String tag;

  const EditButton({super.key, required this.tag});

  PageGetxController get page => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return Obx(() {

      return IconButton(
        tooltip: page.showServices.value
            ? 'All tags'
            : 'Edit tags',
        icon: page.showServices.value
            ? const Icon(Symbols.label_important_outline)
            : const Icon(Symbols.edit_square),
        onPressed: page.showServices.toggle,
      );
    });
  }
}

