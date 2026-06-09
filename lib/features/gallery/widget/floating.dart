import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/widgets/swipable_page.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/utils/theme.dart';
import 'package:hydit/features/search/page/search.dart';
import 'package:hydit/features/settings/page/settings.dart';

import '../getx/gallery.dart';


class FloatingActions extends StatelessWidget {
  final String tag;

  const FloatingActions({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final GalleryController gallery = Get.find(tag: tag);
    return Obx(() {
      return AnimatedContainer(
        curve: Curves.easeOutCubic,
        duration: const Duration(milliseconds: 350),
        height: gallery.actionsVisible
            ? MediaQuery.of(context).viewPadding.bottom * 2
            : 0,
        child: n.Wrap([
          n.Row([
            FilledIconButton(
              onPressed: () => Get.to(
                () => SwipeablePage(child: SettingsPage()),
                opaque: false,
                transition: .rightToLeft,
              ),
              icon: const Icon(Icons.settings),
            ),
            FilledIconButton(
              onPressed: () {
                gallery.hideActions();
                Navigator.of(context).push(
                  BackSwipePageRoute(builder: (context) => Search(tag: tag)),
                );
              },
              icon: const Icon(Icons.search),
            ),
          ])
            ..mainAxisAlignment = .spaceBetween
            ..n.padding = const .only(left: 15.0, right: 15.0, bottom: 15.0),
        ]),
      );
    });
  }
}


class FilledIconButton extends StatelessWidget {
  final Icon icon;
  final EdgeInsets? padding;
  final VoidCallback? onPressed;

  const FilledIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? .zero,
      child: PhysicalModel(
        elevation: 2,
        shape: .circle,
        color: Colors.transparent,
        child: RepaintBoundary(
          child: ClipOval(
            clipBehavior: .hardEdge,
            child: BackdropFilter(
              filter: AppTheme.backdropFilter,
              child: Material(
                color: AppColors.blackWithAlpha,
                child: IconButton(
                  padding: .all(AppTheme.buttonSize * 0.25),
                  onPressed: onPressed,
                  icon: icon,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
