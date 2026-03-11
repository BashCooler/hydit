import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import '../../../core/ui/widget/scroll_to_hide.dart';
import 'package:hydrus_flutter/core/logic/entities.dart';

import 'package:hydrus_flutter/utils/theme.dart';
import 'package:hydrus_flutter/core/ui/widget/widgets.dart';
import 'package:hydrus_flutter/core/ui/getx/controllers.dart';
import 'package:hydrus_flutter/features/gallery/getx/controllers.dart';
import 'package:hydrus_flutter/core/ui/widget/images.dart';
import '../getx/controllers.dart';


class Viewer extends StatefulWidget {
  final int index;

  const Viewer(this.index, {super.key});

  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> with SingleTickerProviderStateMixin {
  late final ZoomController zoomController;
  final multitouchController = MultitouchController();

  @override
  void initState() {
    super.initState();
    zoomController = ZoomController(vsync: this);
    Get.put(PageViewController(initialIndex: widget.index));
  }

  @override
  void dispose() {
    super.dispose();
    zoomController.dispose();
  }

  void showSearchBar(_, _) {
    Future.delayed(
      Duration(milliseconds: 250),
      () {
        Get.find<QueryController>().badgeVisible.value = true;
        Get.find<ScrollToHideController>().show();
      },
    );
  }

  // MARK: BUILD

  @override
  Widget build(BuildContext context) {
    final imgCtrl = Get.find<Images>();
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
          child: FilePageBuilder(
            multitouchCtrl: multitouchController,
            zoomCtrl: zoomController,
            imgCtrl: imgCtrl,
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          // Swipe doesn't work on Windows so I added buttons
          child: _BottomAppBarActions(),
        ),
      ),
    );
  }
}


class FilePageBuilder extends StatelessWidget {
  final MultitouchController multitouchCtrl;
  final ZoomController zoomCtrl;
  final Images imgCtrl;

  const FilePageBuilder({
    super.key,
    required this.multitouchCtrl,
    required this.zoomCtrl,
    required this.imgCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final pageCtrl = Get.find<PageViewController>();
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
        final type = mime.split('/').first;
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
  const _BottomAppBarActions();

  @override
  Widget build(BuildContext context) {
    final pageController = Get.find<PageViewController>().controller;
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
          onPressed: () => _showTagSheet(context),
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

  const _ErrorText(this.type);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Error: media type "$type" is unsupported'),
    );
  }
}

// MARK: SHEET

void _showTagSheet(BuildContext context) {
  Navigator.push(
    context,
    ModalSheetRoute(
      swipeDismissible: true,
      viewportBuilder: (context, child) => SheetViewport(child: child),
      builder: (context) => TagSheet(),
    ),
  );
}


class TagSheet extends StatelessWidget {
  const TagSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final index = Get.find<PageViewController>().currentIndex.value;
    final image = Get.find<Images>().images[index];
    final tags = image.tags;
    final namespaces = tags.keys.toList();
    return SheetKeyboardDismissible(
      dismissBehavior: const .onDragDown(isContentScrollAware: true),
      child: Sheet(
        child: SafeArea(
          child: DefaultTabController(
            length: tags.length,
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  TabBar(
                    isScrollable: true,
                    tabs: namespaces.map((n) => Tab(text: n)).toList(),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: namespaces.map((n) {
                        return ListView.builder(
                          itemCount: tags[n].length ?? 0,
                          reverse: true,
                          shrinkWrap: true,
                          itemBuilder: (context, i) {
                            final tag = Tag(tags[n][i]);
                            return ListTile(title: tag.label);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

