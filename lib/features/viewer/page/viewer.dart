import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydrus_flutter/utils/theme.dart';
import 'package:hydrus_flutter/core/ui/widget/images.dart';
import 'package:hydrus_flutter/core/ui/widget/widgets.dart';
import 'package:hydrus_flutter/core/ui/getx/controllers.dart';
import 'package:hydrus_flutter/core/ui/widget/scroll_to_hide.dart';
import 'package:hydrus_flutter/features/gallery/getx/controllers.dart';
import 'package:preload_page_view/preload_page_view.dart';

import 'tag_sheet.dart';
import '../getx/controllers.dart';


class Viewer extends StatefulWidget {
  final int index;

  const Viewer(this.index, {super.key});

  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> with SingleTickerProviderStateMixin {
  late final ZoomController zoomController;
  late final PageGetxController controller;
  final multitouchController = MultitouchController();
  final imageController = Get.find<Images>();

  @override
  void initState() {
    super.initState();
    zoomController = ZoomController(vsync: this);
    controller = PageGetxController(initial: widget.index);
  }

  @override
  void dispose() {
    super.dispose();
    zoomController.dispose();
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
          onPointerDown: multitouchController.register,
          onPointerUp: multitouchController.register,
          child: Obx(() => PreloadPageView.builder(
            onPageChanged: controller.onPageChanged,
            physics: (multitouchController.multitouch.value || zoomController.zoomed.value)
                ? const NeverScrollableScrollPhysics()
                : const SnappyPageScrollPhysics(),
            controller: controller.c,
            itemCount: imageController.images.length,
            preloadPagesCount: 3,
            itemBuilder: (context, buildIndex) {
              final mime = imageController.images[buildIndex].mime;
              final type = mime.split('/').first;
              final index = controller.index;
              return switch (type) {
                'image' => Obx(() =>
                    ViewImage(zoomController, index.value, buildIndex)),
                'video' => Obx(() =>
                    ViewVideo(controller, index.value, buildIndex)),
                _ => _ErrorText(mime),
              };
            },
          )),
        ),
        // bottomNavigationBar: BottomAppBar(
        //   color: Colors.transparent,
        //   child: _BottomAppBarActions(),
        // ),
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


class _ErrorText extends StatelessWidget {
  final String? type;

  const _ErrorText(this.type);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Error: media type "$type" is unsupported'),
    );
  }
}