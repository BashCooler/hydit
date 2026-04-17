import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';

import 'package:hydrus_flutter/utils/theme.dart';
import 'package:hydrus_flutter/core/ui/widgets.dart';
import 'package:hydrus_flutter/core/domain/di/images.dart';
import 'package:hydrus_flutter/features/editor/page/editor.dart';
import 'package:hydrus_flutter/features/gallery/getx/query.dart';
import 'package:hydrus_flutter/core/external/scroll_to_hide.dart';

import '../widget/views.dart';
import '../getx/page.dart';


class Viewer extends StatefulWidget {
  final int index;

  const Viewer(this.index, {super.key});

  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> with SingleTickerProviderStateMixin {
  late final PageGetxController page;

  static const scroll = SnappyPageScrollPhysics();
  static const noScroll = NeverScrollableScrollPhysics();

  @override
  void initState() {
    super.initState();
    page = Get.put(PageGetxController(initial: widget.index));
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
          onPointerUp: page.registerPointer,
          onPointerDown: page.registerPointer,
          child: Obx(() => PreloadPageView.builder(
            onPageChanged: page.onPageChanged,
            physics: page.noScroll ? noScroll : scroll,
            controller: page.$,
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
    final PageGetxController page = Get.find();
    final Images images = Get.find();
    return Row(
      mainAxisAlignment: .spaceBetween,
      spacing: 10.0,
      children: [
        FilledIconButton(
          onPressed: () => page.$.previousPage(
            duration: const Duration(milliseconds: 150),
            curve: Curves.decelerate,
          ),
          icon: Icon(Icons.keyboard_arrow_left),
        ),
        Expanded(
          child: Obx(() => FilledTextButton(
            text: '${images.$[page.i].length} tags',
            onPressed: () {},
          )),
        ),
        FilledIconButton(
          onPressed: () => Get.to(() => Editor(), transition: .downToUp),
          icon: Icon(Icons.edit_note),
        ),
        FilledIconButton(
          onPressed: () => page.$.nextPage(
            duration: const Duration(milliseconds: 150),
            curve: Curves.decelerate,
          ),
          icon: const Icon(Icons.keyboard_arrow_right),
        ),
      ],
    );
  }
}