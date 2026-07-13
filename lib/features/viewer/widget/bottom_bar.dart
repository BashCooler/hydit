import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/features/viewer/widget/popup.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:hydit/widgets/acrylic.dart' as a;
import 'package:hydit/widgets/gradient.dart';

import '../getx/page.dart';


class ViewerBottomBar extends StatelessWidget {
  final String tag;
  final Widget? editButton;

  const ViewerBottomBar({super.key, required this.tag, this.editButton});

  PageGetxController get page => Get.find(tag: tag);

  static const shadows = [Shadow(blurRadius: 24)];

  @override
  Widget build(BuildContext context) {
    return GradientBottomAppBar(
      child: Row(
        mainAxisSize: .max,
        mainAxisAlignment: .spaceBetween,
        spacing: 10.0,
        children: [
          if (page.files.length > 1)
            a.IconButton(
              tooltip: 'Previous page',
              onPressed: () => page.controller.previousPage(
                duration: const Duration(milliseconds: 150),
                curve: Curves.decelerate,
              ),
              icon: const Icon(Symbols.keyboard_arrow_left),
            )
          else
            const SizedBox.shrink(),

          Obx(() {
            final file = page.current;

            return a.Pill(
              children: [
                a.TextButton(
                  onPressed: page.openSheet,
                  child: a.Text(file.all.length, padding: .zero),
                ),
                page.sheetProgress > 0.5 && editButton != null
                    ? editButton!
                    : ViewerPopup(file: file),
              ],
            );
          }),

          if (page.files.length > 1)
            a.IconButton(
              tooltip: 'Next page',
              icon: const Icon(Symbols.keyboard_arrow_right),
              onPressed: () => page.controller.nextPage(
                duration: const Duration(milliseconds: 150),
                curve: Curves.decelerate,
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}