import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:preload_page_view/preload_page_view.dart';

import 'package:hydrus_flutter/utils/theme.dart';
import 'package:hydrus_flutter/core/ui/common.dart';
import 'package:hydrus_flutter/core/ui/tag_list.dart';
import 'package:hydrus_flutter/core/domain/di/images.dart';
import 'package:hydrus_flutter/features/editor/page/editor.dart';
import 'package:hydrus_flutter/features/gallery/getx/query.dart';
import 'package:hydrus_flutter/core/external/scroll_to_hide.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

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

  @override
  void initState() {
    super.initState();
    page = Get.put(PageGetxController(initial: widget.index));
    Get.put(SnappingSheetController());
  }

  void showSearchBar(_, _) {
    Future.delayed(Duration(milliseconds: 250), () {
      Get.find<QueryController>().badgeVisible.value = true;
      Get.find<ScrollToHideController>().show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: showSearchBar,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: Obx(() => DismissiblePage(
          disabled: page.noScroll,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          onDismissed: () => Navigator.of(context).pop(),
          direction: .down,
          interactionMode: .gesture,
          minScale: 0,
          builder: (BuildContext context, ScrollController scrollController) {
            return const Pages();
          },
        )),
        bottomNavigationBar: const BottomActions(),
      ),
    );
  }
}


class Pages extends StatelessWidget {
  const Pages({super.key});

  static const scroll = SnappyPageScrollPhysics();
  static const noScroll = NeverScrollableScrollPhysics();

  @override
  Widget build(BuildContext context) {

    final Images images = Get.find();
    final PageGetxController page = Get.find();

    return Listener(
      onPointerUp: page.registerPointer,
      onPointerDown: page.registerPointer,
      child: Obx(() => PreloadPageView.builder(
        onPageChanged: page.onPageChanged,
        physics: page.noScroll ? noScroll : scroll,
        controller: page.controller,
        itemCount: images.length,
        preloadPagesCount: 3,
        itemBuilder: (_, index) => ViewFile(index),
      )),
    );
  }
}


class BottomActions extends StatelessWidget {
  const BottomActions({super.key});

  @override
  Widget build(BuildContext context) {

    final PageGetxController page = Get.find();
    final Images images = Get.find();

    return BottomAppBar(
      color: Colors.transparent,
      child: Row(
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
              text: '${images[page.i].length} tags',
              onPressed: () {}, // TODO открывать теги отсюда
            )),
          ),
          FilledIconButton(
            onPressed: () {
              Get.to(() => Editor(), transition: .downToUp);
            },
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
      ),
    );
  }
}