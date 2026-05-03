import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:hydrus_flutter/features/viewer/getx/page.dart';

import 'package:hydrus_flutter/features/viewer/widget/views.dart';


class Preview extends StatelessWidget {
  final int index;
  final String tag;

  const Preview({
    super.key,
    required this.index,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final PageGetxController page = Get.find(tag: tag);

    return PopScope(
      child: Obx(() {
        return DismissiblePage(
          disabled: page.zoom.value,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          onDismissed: Navigator.of(context).pop,
          direction: .vertical,
          interactionMode: .gesture,
          minScale: 0,
          builder: (context, scrollController) {
            return ViewFile(index, tag: tag);
          },
        );
      }),
    );
  }
}
