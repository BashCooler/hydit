import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydrus_flutter/core/ui/suggests.dart';
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
        bottomNavigationBar: _BottomAppBar(),
      ),
    );
  }
}


class _BottomAppBar extends HookWidget {
  const _BottomAppBar();

  @override
  Widget build(BuildContext context) {

    final PageGetxController page = Get.find();
    final Images images = Get.find();

    return Obx(() => PortalTarget(
      visible: page.overlay.value,
      anchor: const Aligned(follower: .bottomLeft, target: .topLeft),
      portalFollower: GestureDetector(
        behavior: .opaque,
        onTap: () => page.overlay.value = false,
        child: Container(
          padding: .symmetric(horizontal: AppTheme.outerPadding),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          child: Material(
            color: AppColors.blackWithAlpha,
            borderRadius: .circular(AppTheme.radius),
            child: TagList(
              trailing: const SizedBox.shrink(),
              tags: images.$[page.i].service['all known tags'],
            ),
          ),
        ),
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: .spaceBetween,
          spacing: 10.0,
          children: [
            FilledIconButton(
              onPressed: !page.overlay.value ? () => page.$.previousPage(
                duration: const Duration(milliseconds: 150),
                curve: Curves.decelerate,
              ) : null,
              icon: Icon(Icons.keyboard_arrow_left),
            ),
            Expanded(
              child: Obx(() => FilledTextButton(
                text: '${images.$[page.i].length} tags',
                onPressed: () => page.overlay.value = !page.overlay.value,
              )),
            ),
            FilledIconButton(
              onPressed: () {
                page.overlay.value = false;
                Get.to(() => Editor(), transition: .downToUp);
              },
              icon: Icon(Icons.edit_note),
            ),
            FilledIconButton(
              onPressed: !page.overlay.value ? () => page.$.nextPage(
                duration: const Duration(milliseconds: 150),
                curve: Curves.decelerate,
              ) : null,
              icon: const Icon(Icons.keyboard_arrow_right),
            ),
          ],
        ),
      ),
    ));
  }
}