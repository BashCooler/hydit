import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydrus_flutter/viewer/images.dart';
import '../main.dart';
import '../search/search.dart';
import 'controllers.dart';


class Viewer extends WatchingStatefulWidget {
  final int index;

  const Viewer({super.key, required this.index});

  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> with SingleTickerProviderStateMixin {

  final images = getIt<GetImages>().value;

  late final ZoomController _zoomCtrl;
  final _multitouchCtrl = MultitouchController();
  final observerCtrl = getIt<GridObserverController>();

  @override
  void initState() {
    super.initState();
    _zoomCtrl = ZoomController(vsync: this);
    getIt.pushNewScope(
      init: (getIt) {
        getIt.registerSingleton(PageViewController(initialIndex: widget.index));
      }
    );
  }

  @override
  void dispose() {
    super.dispose();
    _zoomCtrl.dispose();
  }

  // MARK: BUILD

  @override
  Widget build(BuildContext context) {
    final pageCtrl = getIt<PageViewController>();
    // Watch multitouch state
    final mCtrl = createOnce(() => _multitouchCtrl.isMultitouch);
    final isMultitouch = watch(mCtrl).value;
    // Watch zoom state
    final zCtrl = createOnce(() => _zoomCtrl.isZoomed);
    final isZoomed = watch(zCtrl).value;
    // Watch page state
    final pCtrl = createOnce(() => pageCtrl.currentIndex);
    final curIndex = watch(pCtrl).value;
    // Build widget
    return PopScope(
      onPopInvokedWithResult: (closed, object) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          getIt<SearchVisibilityController>().show();
        });
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: Listener(
          onPointerDown: _multitouchCtrl.register,
          onPointerUp: _multitouchCtrl.register,
          child: PageView.builder(
            allowImplicitScrolling: true,
            onPageChanged: pageCtrl.onPageChanged,
            physics: (isMultitouch || isZoomed)
                ? const NeverScrollableScrollPhysics()
                : const SnappyPageScrollPhysics(),
            controller: pageCtrl.pageController,
            itemCount: images.length,
            itemBuilder: (context, buildIndex) {
              final mime = images[buildIndex].mime;
              final type = mime?.split('/').first;
              return switch (type) {
                'image' => ViewImage(_zoomCtrl, curIndex, buildIndex),
                'video' => ViewVideo(curIndex, buildIndex),
                _ => ErrorText(mime),
              };
            },
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
