import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../getx/base.dart';
import '../getx/single.dart';


class const EditorBottomBar({
  super.key,
  required final String tag,
  required final Future<bool> Function() callback,
  required final Widget child,
}) extends StatelessWidget {
  //
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
