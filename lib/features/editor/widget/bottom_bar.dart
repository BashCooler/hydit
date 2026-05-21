import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/core/domain/file_repo.dart';
import 'package:hydit/features/viewer/getx/page.dart';

import '../getx/tags.dart';
import '../page/editor.dart';
import 'search_bar.dart';


class EditorBottomBar extends StatelessWidget {
  final String tag;
  final Future<bool> Function(String tag) callback;
  final Mode mode;

  const EditorBottomBar({
    super.key,
    required this.tag,
    required this.callback,
    required this.mode,
  });

  Future<void> navigateToPage(int target) async {
    final FileRepo files = Get.find(tag: tag);
    final TagManager manager = Get.find();
    final PageGetxController page = Get.find(tag: tag);

    if (target < 0) return;
    if (target >= files.length) return;

    final shouldSwitch = await callback(tag);
    if (!shouldSwitch) return;

    page.navigateToPage(target);
    manager.init(files[page.i]);
  }

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case .paged:
        final PageGetxController page = Get.find(tag: tag);
        return n.Row([
          IconButton(
            tooltip: 'Previous page',
            icon: const Icon(Icons.keyboard_arrow_left),
            onPressed: () => navigateToPage(page.i - 1),
          ),
          EditorTagSearchBar(tag: tag).niku..expanded,
          IconButton(
            tooltip: 'Next page',
            icon: const Icon(Icons.keyboard_arrow_right),
            onPressed: () => navigateToPage(page.i + 1),
          ),
        ]);
      case .batch:
        return EditorTagSearchBar(tag: tag);
    }
  }
}