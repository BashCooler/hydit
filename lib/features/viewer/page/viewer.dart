import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to_hide/scroll_to_hide.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:preload_page_view/preload_page_view.dart';

import 'package:hydrus_flutter/core/ui/common.dart';
import 'package:hydrus_flutter/core/domain/di/images.dart';
import 'package:hydrus_flutter/features/search/getx/query.dart';
import 'package:hydrus_flutter/features/viewer/widget/tag_sheet.dart';

import '../widget/views.dart';
import '../getx/page.dart';


class Viewer extends StatefulWidget {
  final int index;
  final String tag;

  const Viewer(this.index, {super.key, required this.tag});

  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  void showSearchBar(_, _) async {
    Future.delayed(Duration(milliseconds: 250), () {
      if (!mounted) return;
      Get.find<QueryController>().badgeVisible.value = true;
      Get.find<ScrollToHideController>().show();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Images images = Get.find();
    final PageGetxController page = Get.find(tag: widget.tag);

    return PopScope(
      onPopInvokedWithResult: showSearchBar,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: Get.mediaQuery.viewInsets.top,
          backgroundColor: Get.theme.scaffoldBackgroundColor.withAlpha(90),
        ),
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: Obx(() {
          return TagSheet(
            tags: images[page.i].all,
            tag: widget.tag,
            child: Pages(tag: widget.tag),
          );
        }),
        bottomNavigationBar: BottomActions(tag: widget.tag),
      ),
    );
  }
}


class Pages extends StatelessWidget {
  final String tag;

  const Pages({super.key, required this.tag});

  static const scroll = SnappyPageScrollPhysics();
  static const noScroll = NeverScrollableScrollPhysics();

  @override
  Widget build(BuildContext context) {
    final Images images = Get.find();
    final PageGetxController page = Get.find(tag: tag);

    return Listener(
      onPointerUp: page.registerPointer,
      onPointerDown: page.registerPointer,
      child: Obx(() {
        return PreloadPageView.builder(
          onPageChanged: page.onPageChanged,
          physics: page.noScroll ? noScroll : scroll,
          controller: page.controller,
          itemCount: images.length,
          preloadPagesCount: 3,
          itemBuilder: (_, index) {
            return DismissibleFile(index, tag: tag);
          },
        );
      }),
    );
  }
}


class DismissibleFile extends StatelessWidget {
  final int index;
  final String tag;

  const DismissibleFile(this.index, {super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final PageGetxController page = Get.find(tag: tag);

    return Obx(() {
      return DismissiblePage(

        disabled: page.blockDismiss,
        backgroundColor: Theme
            .of(context)
            .scaffoldBackgroundColor,
        onDismissed: Navigator
            .of(context)
            .pop,
        direction: .vertical,
        interactionMode: .gesture,
        minScale: 0,
        builder: (context, scrollController) {
          return ViewFile(index, tag: tag);
        },
      );
    });
  }
}



class BottomActions extends StatelessWidget {
  final String tag;

  const BottomActions({super.key, required this.tag});

  void openSheet() {
    final SnappingSheetController sheet = Get.find(tag: tag);
    sheet.snapToPosition(.factor(positionFactor: 0.5));
  }

  @override
  Widget build(BuildContext context) {
    final PageGetxController page = Get.find(tag: tag);
    final Images images = Get.find();

    return BottomAppBar(
      color: Get.theme.scaffoldBackgroundColor.withAlpha(90),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        spacing: 10.0,
        children: [
          IconButton(
            color: Colors.white,
            onPressed: () => page.$.previousPage(
              duration: const Duration(milliseconds: 150),
              curve: Curves.decelerate,
            ),
            icon: const Icon(Icons.keyboard_arrow_left),
          ),
          Expanded(
            child: Obx(() => TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: .w500,
                  shadows: const <Shadow>[
                    .new(
                      color: Colors.black,
                      blurRadius: 24,
                      offset: Offset(0, 0),
                    ),
                  ]
                ),
              ),
              onPressed: openSheet,
              child: Text('${images[page.i].length} tags'),
            )),
          ),
          IconButton(
            color: Colors.white,
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
