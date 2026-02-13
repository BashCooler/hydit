import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydrus_flutter/core/ui/getx/controllers.dart';
import '../widget/images.dart';
import '../getx/controllers.dart';


class Viewer extends StatefulWidget {
  final int index;

  const Viewer(this.index, {super.key});

  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> with SingleTickerProviderStateMixin {

  final imgCtrl = Get.find<Images>();

  late final ZoomController zoomController;
  late final PageViewController pageController;
  final multitouchController = MultitouchController();
  final observerController = Get.find<GridObserverController>();

  @override
  void initState() {
    super.initState();
    zoomController = ZoomController(vsync: this);
    pageController = PageViewController(initialIndex: widget.index);
  }

  @override
  void dispose() {
    super.dispose();
    zoomController.dispose();
  }

  void showSearchBar(_, _) {
    Future.delayed(
      Duration(milliseconds: 32),
      () => Get.find<SearchVisibility>().show(),
    );
  }

  // MARK: BUILD

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: showSearchBar,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: Listener(
          onPointerDown: multitouchController.register,
          onPointerUp: multitouchController.register,
          child: FilePageBuilder(
            pageCtrl: pageController,
            multitouchCtrl: multitouchController,
            zoomCtrl: zoomController,
            imgCtrl: imgCtrl,
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          // Swipe doesn't work on Windows so I added buttons
          child: _BottomAppBarActions(
            pageController: pageController.controller,
          ),
        ),
      ),
    );
  }
}


class FilePageBuilder extends StatelessWidget {
  final PageViewController pageCtrl;
  final MultitouchController multitouchCtrl;
  final ZoomController zoomCtrl;
  final Images imgCtrl;

  const FilePageBuilder({
    super.key,
    required this.pageCtrl,
    required this.multitouchCtrl,
    required this.zoomCtrl,
    required this.imgCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => PageView.builder(
      allowImplicitScrolling: true,
      onPageChanged: pageCtrl.onPageChanged,
      physics: (multitouchCtrl.multitouch.value || zoomCtrl.zoomed.value)
          ? const NeverScrollableScrollPhysics()
          : const SnappyPageScrollPhysics(),
      controller: pageCtrl.controller,
      itemCount: imgCtrl.images.length,
      itemBuilder: (context, buildIndex) {
        final mime = imgCtrl.images[buildIndex].mime;
        final type = mime?.split('/').first;
        final index = pageCtrl.currentIndex;
        return switch (type) {
          'image' => Obx(() =>
              ViewImage(zoomCtrl, index.value, buildIndex)),
          'video' => Obx(() =>
              ViewVideo(pageCtrl, index.value, buildIndex)),
          _ => _ErrorText(mime),
        };
      },
    ));
  }
}


class _BottomAppBarActions extends StatelessWidget {
  const _BottomAppBarActions({required PageController pageController})
      : _pageController = pageController;

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


class _ErrorText extends StatelessWidget {
  final String? type;

  const _ErrorText(this.type, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Error: media type "$type" is unsupported'),
    );
  }
}
