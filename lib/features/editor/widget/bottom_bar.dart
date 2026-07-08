import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import '../getx/base.dart';
import '../getx/single.dart';


class EditorBottomBar extends StatelessWidget {
  final String tag;
  final Future<bool> Function() callback;
  final Widget child;

  const EditorBottomBar({
    super.key,
    required this.tag,
    required this.callback,
    required this.child,
  });

  TagManager get manager => Get.find(tag: tag);

  /// Select next file.
  Future<void> next() async {
    if (!await callback()) return;

    final manager = this.manager as PagedTagManager;
    manager.page.next();
    manager.init();
  }

  /// Select previous file.
  Future<void> previous() async {
    if (!await callback()) return;

    final manager = this.manager as PagedTagManager;
    manager.page.previous();
    manager.init();
  }

  @override
  Widget build(BuildContext context) {
    final paged = manager is PagedTagManager;

    return Padding(
      padding: const .symmetric(horizontal: 5),
      child: n.Row([
        if (paged)
          IconButton(
            tooltip: 'Previous page',
            icon: const Icon(Icons.keyboard_arrow_left),
            onPressed: previous,
          ),

        Expanded(child: child),

        IconButton(
          tooltip: 'Save',
          icon: const Icon(Icons.save),
          onPressed: Navigator.of(context).maybePop,
        ),

        if (paged)
          IconButton(
            tooltip: 'Next page',
            icon: const Icon(Icons.keyboard_arrow_right),
            onPressed: next,
          ),
      ]),
    );
  }
}
