import 'package:get/get.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(horizontal: 5),
      child: Row(
        children: [
          if (manager case PagedTagManager(page: final page) && final manager)
            if (page.files.length > 1)
              IconButton(
                tooltip: 'Previous page',
                icon: const Icon(Icons.keyboard_arrow_left),
                onPressed: () async {
                  if (await callback()) {
                    manager..page.jumpPrevious()..init();
                  }
                },
              ),

          Expanded(child: child),

          IconButton(
            tooltip: 'Save',
            icon: const Icon(Icons.save),
            onPressed: Navigator.of(context).maybePop,
          ),

          if (manager case PagedTagManager(page: final page) && final manager)
            if (page.files.length > 1)
              IconButton(
                tooltip: 'Next page',
                icon: const Icon(Icons.keyboard_arrow_right),
                onPressed: () async {
                  if (await callback()) {
                    manager..page.jumpNext()..init();
                  }
                },
              ),
        ],
      ),
    );
  }
}
