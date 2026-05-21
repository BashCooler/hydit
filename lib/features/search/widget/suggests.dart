import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/core/ui/tag_list.dart';
import 'package:hydit/core/domain/entities.dart';

import '../getx/query.dart';


class Suggests extends StatelessWidget {
  final Widget? trailing;
  final bool expanded;
  final ScrollController? scrollController;
  final void Function(Tag tag)? onTap;
  final String? tag;

  const Suggests({
    super.key,
    this.expanded = true,
    this.scrollController,
    this.trailing,
    required this.onTap,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final QueryController controller = Get.find(tag: tag);
    return Obx(() {
      switch (controller.suggestsVisible) {
        case true:
          return TagList(
            trailing: trailing,
            onTap: onTap,
            scrollController: scrollController,
            tags: controller.suggests.toList(),
            reverse: true,
          );
        case false:
          return const Center();
      }
    });
  }
}
