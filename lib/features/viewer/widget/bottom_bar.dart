import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

import 'package:hydit/widgets/acrylic.dart' as a;
import 'package:hydit/widgets/gradient.dart';
import 'package:hydit/reactive/file_store.dart';

import '../getx/page.dart';


class BottomActions extends StatelessWidget {
  final String tag;

  const BottomActions({super.key, required this.tag});

  void openSheet() {
    final SnappingSheetController sheet = Get.find(tag: tag);
    sheet.snapToPosition(.factor(positionFactor: 0.5));
  }

  static const shadows = [Shadow(blurRadius: 24)];

  @override
  Widget build(BuildContext context) {
    final PageGetxController page = Get.find(tag: tag);
    final FileStore files = Get.find(tag: tag);

    return GradientBottomAppBar(
      child: Row(
        mainAxisAlignment: .spaceBetween,
        spacing: 10.0,
        children: [
          a.IconButton(
            tooltip: 'Previous page',
            onPressed: () => page.controller.previousPage(
              duration: const Duration(milliseconds: 150),
              curve: Curves.decelerate,
            ),
            icon: const Icon(Icons.keyboard_arrow_left),
          ),

          Obx(() {
            final file = files[page.i];
            if (file.loading) return const SizedBox.shrink();

            return a.Pill(
              children: [
                a.TextButton(
                  onPressed: openSheet,
                  child: Obx(() => a.Text(file.meta!.length, padding: .zero)),
                ),
                IconButton(
                  tooltip: 'Edit tags',
                  icon: const Icon(Icons.edit),
                  onPressed: () {},
                ),
              ],
            );
          }),

          a.IconButton(
            tooltip: 'Next page',
            icon: const Icon(Icons.keyboard_arrow_right),
            onPressed: () => page.controller.nextPage(
              duration: const Duration(milliseconds: 150),
              curve: Curves.decelerate,
            ),
          ),
        ],
      ),
    );
  }
}