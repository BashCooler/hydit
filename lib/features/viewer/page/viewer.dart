import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydrus_flutter/features/viewer/getx/transform.dart';

import 'package:hydrus_flutter/utils/theme.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:hydrus_flutter/core/ui/widget/widgets.dart';
import 'package:hydrus_flutter/core/ui/getx/controllers.dart';
import 'package:hydrus_flutter/core/ui/widget/scroll_to_hide.dart';
import 'package:hydrus_flutter/features/gallery/getx/controllers.dart';

import 'tag_sheet.dart';
import '../widget/views.dart';
import '../getx/page.dart';


class Viewer extends StatefulWidget {
  final int index;

  const Viewer(this.index, {super.key});

  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> with SingleTickerProviderStateMixin {
  late final TransformController transform;
  late final PageGetxController controller;

  static const scroll = SnappyPageScrollPhysics();
  static const noScroll = NeverScrollableScrollPhysics();

  @override
  void initState() {
    super.initState();
    controller = Get.put(PageGetxController(initial: widget.index));
    transform = Get.put(TransformController(
      minScale: 1.0,
      maxScale: 4.0,
      vsync: this,
    ));
  }

  void showSearchBar(_, _) {
    Future.delayed(Duration(milliseconds: 250), () {
      Get.find<QueryController>().badgeVisible.value = true;
      Get.find<ScrollToHideController>().show();
    });
  }

  // MARK: BUILD

  @override
  Widget build(BuildContext context) {
    final images = Get.find<Images>();
    return PopScope(
      onPopInvokedWithResult: showSearchBar,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          actionsPadding: .all(AppTheme.outerPadding),
          toolbarHeight: AppTheme.buttonSize + AppTheme.outerPadding * 2,
          actions: [
            Expanded(
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  FilledIconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back),
                  ),
                ],
              ),
            )
          ],
        ),
        body: Listener(
          onPointerUp: transform.registerPointer,
          onPointerDown: transform.registerPointer,
          child: Obx(() => PreloadPageView.builder(
            onPageChanged: controller.onPageChanged,
            physics: transform.noScroll ? noScroll : scroll,
            controller: controller.$,
            itemCount: images.$.length,
            preloadPagesCount: 3,
            itemBuilder: (_, index) => ViewFile(index),
          )),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          child: _BottomAppBarActions(),
        ),
      ),
    );
  }
}


class _BottomAppBarActions extends StatelessWidget {
  const _BottomAppBarActions();

  @override
  Widget build(BuildContext context) {
    final pageController = Get.find<PageGetxController>().controller;
    return Row(
      mainAxisAlignment: .spaceBetween,
      spacing: 10.0,
      children: [
        FilledIconButton(
          onPressed: () => pageController.previousPage(
            duration: const Duration(milliseconds: 150),
            curve: Curves.decelerate,
          ),
          icon: Icon(Icons.keyboard_arrow_left),
        ),
        Expanded(child: Center()),
        FilledIconButton(
          onPressed: () => showTagSheet(context),
          icon: Icon(Icons.tag),
        ),
        FilledIconButton(
          onPressed: () => pageController.nextPage(
            duration: const Duration(milliseconds: 150),
            curve: Curves.decelerate,
          ),
          icon: const Icon(Icons.keyboard_arrow_right),
        ),
      ],
    );
  }
}