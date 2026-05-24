import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/core/ui/common.dart';
import 'package:hydit/features/search/page/search.dart';
import 'package:hydit/features/settings/ui/page/settings.dart';

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
              onPressed: () {
                Get.to(() => const SettingsPage(), transition: .downToUp);
              },
              icon: const Icon(Icons.settings),
            ),
            FilledIconButton(
              onPressed: () {
                gallery.hideActions();
                Get.to(() => Search(tag: tag), transition: .downToUp);
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