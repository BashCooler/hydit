import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dismissible_page/dismissible_page.dart';

import 'package:hydit/core/state/file.dart';

import '../getx/page.dart';
import '../widget/views.dart';


class Preview extends StatelessWidget {
  final int index;
  final String tag;
  final HydrusFile file;

  const Preview({
    super.key,
    required this.index,
    required this.tag,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    final PageGetxController page = Get.find(tag: tag);

    return PopScope(
      child: Obx(() {
        return DismissiblePage(
          disabled: page.zoom.value,
          backgroundColor: Get.theme.scaffoldBackgroundColor,
          onDismissed: Get.back,
          direction: .vertical,
          interactionMode: .gesture,
          minScale: 0,
          builder: (context, scrollController) {
            return ViewFile(tag: tag, index: index, file: file);
          },
        );
      }),
    );
  }
}
