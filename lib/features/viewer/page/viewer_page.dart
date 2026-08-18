import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:preload_page_view/preload_page_view.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/widgets/systems/gradient.dart';

import '../getx/page.dart';
import '../getx/sheet.dart';
import '../getx/gesture.dart';
import '../widget/widgets.dart';


class Viewer extends StatelessWidget {
  final String tag;

  const Viewer({
    super.key,
    required this.tag,
  });

  SheetController get sheet => Get.find(tag: tag);

  void closeOrBack() => sheet.progress.value > 0.5
      ? sheet.close()
      : Get.back();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        closeOrBack();
      },
      child: Scaffold(
        appBar: GradientAppBar(automaticallyImplyLeading: false),
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: TagSheet(
          tag: tag,
          child: Pages(tag: tag),
        ),
        bottomNavigationBar: ViewerBottomBar(tag: tag),
      ),
    );
  }
}

class Pages extends StatelessWidget {
  final String tag;

  const Pages({super.key, required this.tag});

  static const scroll = SnappyPageScrollPhysics();
  static const noScroll = NeverScrollableScrollPhysics();

  PageGetxController get page => Get.find(tag: tag);

  GestureController get gesture => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: gesture.registerPointer,
      onPointerDown: gesture.registerPointer,
      child: Obx(() {
        return PreloadPageView.builder(
          onPageChanged: page.onPageChanged,
          physics: gesture.interacting ? noScroll : scroll,
          controller: page.controller,
          itemCount: page.files.length,
          preloadPagesCount: 3,
          itemBuilder: (context, index) {
            return DismissibleFile(
              tag: tag,
              index: index,
              file: page.files[index],
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

  static const threshold = 0.035;

  PageGetxController get page => Get.find(tag: tag);

  SheetController get sheet => Get.find(tag: tag);

  GestureController get gesture => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return Obx(() {

      return DismissiblePage(
        disabled: gesture.zoom || sheet.opened,
        backgroundColor: Theme
            .of(context)
            .scaffoldBackgroundColor,
        onDismissed: Get.back,
        direction: .vertical,
        interactionMode: .gesture,
        minScale: 0,
        dragSensitivity: 1,
        dismissThresholds: {
          DismissiblePageDismissDirection.down: threshold,
          DismissiblePageDismissDirection.up: threshold,
        },
        builder: (context, scrollController) {
          final prefix = Get.arguments?['heroPrefix'];

          return Obx(
            () => AnimatedScale(
              scale: file.removed ? 0 : 1,
              duration: deletionDuration,
              child: ViewFile(
                tag: tag,
                index: index,
                file: file,
                heroTag: prefix != null ? '$prefix${file.id}' : file.id,
              ),
            ),
          );
        },
      );
    });
  }
}
