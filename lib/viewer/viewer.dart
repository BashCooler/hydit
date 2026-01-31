import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydrus_flutter/viewer/images.dart';
import 'package:hydrus_flutter/search/search.dart';
import 'controllers.dart';


class Viewer extends StatefulWidget {
  final int index;

  const Viewer(this.index, {super.key});

  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> with SingleTickerProviderStateMixin {

  final imgCtrl = Get.find<Images>();

  late final ZoomController zoomCtrl;
  late final PageViewController pageCtrl;
  final multitouchCtrl = MultitouchController();
  final observerCtrl = Get.find<GridObserverController>();

  @override
  void initState() {
    super.initState();
    zoomCtrl = ZoomController(vsync: this);
    pageCtrl = PageViewController(initialIndex: widget.index);
  }

  @override
  void dispose() {
    super.dispose();
    zoomCtrl.dispose();
  }

  void showSearchBar(_, _) => Future.delayed(Duration(milliseconds: 32), () {
    Get.find<SearchVisibility>().show();
  });

  // MARK: BUILD

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: showSearchBar,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: Obx(
          () => Listener(
            onPointerDown: multitouchCtrl.register,
            onPointerUp: multitouchCtrl.register,
            child: PageView.builder(
              allowImplicitScrolling: true,
              onPageChanged: pageCtrl.onPageChanged,
              physics: (multitouchCtrl.isMultitouch.value || zoomCtrl.isZoomed.value)
                  ? const NeverScrollableScrollPhysics()
                  : const SnappyPageScrollPhysics(),
              controller: pageCtrl.pageController,
              itemCount: imgCtrl.images.length,
              itemBuilder: (context, buildIndex) {
                final mime = imgCtrl.images[buildIndex].mime;
                final type = mime?.split('/').first;
                final currentIndex = pageCtrl.currentIndex;
                return switch (type) {
                  'image' => Obx(() =>
                      ViewImage(zoomCtrl, currentIndex.value, buildIndex)),
                  'video' => Obx(() =>
                      ViewVideo(pageCtrl, currentIndex.value, buildIndex)),
                  _ => ErrorText(mime),
                };
              },
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          // Swipe doesn't work on Windows for some reason so I added buttons
          child: BottomAppBarActions(pageController: pageCtrl.pageController),
        ),
      ),
    );
  }
}


class BottomAppBarActions extends StatelessWidget {
  const BottomAppBarActions({
    super.key,
    required PageController pageController,
  }) : _pageController = pageController;

  final PageController _pageController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        IconButton(
          onPressed: () => _pageController.previousPage(
            duration: const Duration(milliseconds: 150),
            curve: Curves.decelerate,
          ),
          icon: Icon(Icons.keyboard_arrow_left),
        ),
        IconButton(
          onPressed: () => _pageController.nextPage(
            duration: const Duration(milliseconds: 150),
            curve: Curves.decelerate,
          ),
          icon: const Icon(Icons.keyboard_arrow_right),
        ),
      ],
    );
  }
}


/// Makes [PageView] scroll more responsive. Still not perfect.
class SnappyPageScrollPhysics extends PageScrollPhysics {
  const SnappyPageScrollPhysics({super.parent});

  @override
  SnappyPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SnappyPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
    mass: 1,
    stiffness: 250,
    damping: 30,
  );
}


class ErrorText extends StatelessWidget {
  final String? type;

  const ErrorText(this.type, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Error: media type "$type" is unsupported'),
    );
  }
}
