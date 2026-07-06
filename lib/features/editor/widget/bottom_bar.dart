import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/features/editor/getx/base.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/viewer/getx/page.dart';

import '../getx/single.dart';


class EditorBottomBar extends StatelessWidget {
  final String tag;
  final Future<bool> Function() callback;
  final bool navigation;
  final Widget child;

  const EditorBottomBar({
    super.key,
    required this.tag,
    required this.callback,
    required this.navigation,
    required this.child,
  });

  TagManager get manager => Get.find();
  FileStore get files => Get.find(tag: tag);
  PageGetxController get page => Get.find(tag: tag);

  Future<void> navigateToPage(int target) async {
    if (target < 0) return;
    if (target >= files.length) return;

    if (!await callback()) return;

    page.navigateToPage(target);

    final manager = this.manager as SingleTagManager;
    manager.init(files[page.i]);
  }

  @override
  Widget build(BuildContext context) {

    if (!navigation) {
      return child;
    }

    return Padding(
      padding: .symmetric(horizontal: 5),
      child: n.Row([
        IconButton(
          tooltip: 'Previous page',
          icon: const Icon(Icons.keyboard_arrow_left),
          onPressed: () => navigateToPage(page.i - 1),
        ),
        Expanded(child: child),
        IconButton(
          tooltip: 'Next page',
          icon: const Icon(Icons.keyboard_arrow_right),
          onPressed: () => navigateToPage(page.i + 1),
        ),
      ]),
    );
  }
}