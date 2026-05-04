import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydrus_flutter/core/domain/di/images.dart';
import 'package:hydrus_flutter/features/viewer/getx/page.dart';

import '../getx/tags.dart';
import 'search_bar.dart';


class PagedEditorBottomBar extends StatelessWidget {
  final String tag;
  final Future<bool> Function(String tag) callback;

  const PagedEditorBottomBar({
    super.key,
    required this.tag,
    required this.callback,
  });

  Future<void> navigateToPage(int target) async {
    final Images images = Get.find();
    final TagManager manager = Get.find();
    final PageGetxController page = Get.find(tag: tag);

    if (target < 0) return;
    if (target >= images.length) return;

    final shouldSwitch = await callback(tag);
    if (!shouldSwitch) return;

    page.navigateToPage(target);
    manager.init(images[page.i].service);
  }

  @override
  Widget build(BuildContext context) {
    final PageGetxController page = Get.find(tag: tag);
    return n.Row([
      IconButton(
        tooltip: 'Previous page',
        icon: const Icon(Icons.keyboard_arrow_left),
        onPressed: () => navigateToPage(page.i - 1),
      ),
      EditorTagSearchBar(tag: tag).niku
        ..expanded,
      IconButton(
        tooltip: 'Next page',
        icon: const Icon(Icons.keyboard_arrow_right),
        onPressed: () => navigateToPage(page.i + 1),
      ),
    ]);
  }
}