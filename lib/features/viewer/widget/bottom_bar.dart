import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:hydit/services/services.dart';
import 'package:hydit/features/viewer/widget/popup.dart';
import 'package:hydit/widgets/systems/acrylic.dart' as a;
import 'package:hydit/widgets/systems/gradient.dart';

import '../getx/sheet.dart';
import '../getx/page.dart';


class ViewerBottomBar extends StatelessWidget {
  final String tag;

  const ViewerBottomBar({super.key, required this.tag});

  bool get editor => Get.arguments?['editor'] ?? false;

  PageGetxController get page => Get.find(tag: tag);

  SheetController get sheet => Get.find(tag: tag);

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
              onPressed: page.previousPage,
              icon: const Icon(Symbols.keyboard_arrow_left),
            )
          else
            const SizedBox.shrink(),

          Obx(() {
            final file = page.current;

            return a.Pill(
              children: [
                ArchiveButton(tag: tag),
                a.TextButton(
                  onPressed: sheet.open,
                  child: a.Text(file.all.length, padding: .zero),
                ),
                sheet.progress > 0.5 && editor
                    ? EditButton(tag: tag)
                    : ViewerPopup(tag: tag),
              ],
            );
          }),

          if (page.files.length > 1)
            a.IconButton(
              tooltip: 'Next page',
              icon: const Icon(Symbols.keyboard_arrow_right),
              onPressed: page.nextPage,
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}


class EditButton extends StatelessWidget {
  final String tag;

  const EditButton({super.key, required this.tag});

  PageGetxController get page => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return Obx(() {

      return IconButton(
        tooltip: page.showServices.value
            ? 'All tags'
            : 'Edit tags',
        icon: page.showServices.value
            ? const Icon(Symbols.label)
            : const Icon(Symbols.edit_square),
        onPressed: page.showServices.toggle,
      );
    });
  }
}


class ArchiveButton extends StatelessWidget {
  final String tag;

  const ArchiveButton({super.key, required this.tag});

  Repo get repo => Get.find();

  PageGetxController get page => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) => Obx(() {
    return IconButton(
      icon: page.current.isInbox
          ? Icon(Symbols.inventory_2)
          : Icon(Symbols.mail_outline),
      tooltip: page.current.isInbox
          ? 'Archive'
          : 'Inbox',
      onPressed: () {
        page.current.toggleInbox()
            .tapFailure(Snack.error);
      },
    );
  });
}
