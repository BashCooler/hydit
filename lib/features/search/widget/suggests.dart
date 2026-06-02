import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/core/widget/tag_list.dart';
import 'package:hydit/core/entity/tag.dart';

import '../getx/search.dart';


class Suggests extends StatelessWidget {
  final Widget? trailing;
  final ScrollController? scrollController;
  final void Function(Tag tag)? onTap;
  final TagSearchController tagSearchController;

  const Suggests({
    super.key,
    this.scrollController,
    this.trailing,
    required this.onTap,
    required this.tagSearchController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (tagSearchController.suggestsVisible) {
        case true:
          return TagList(
            trailing: trailing,
            onTap: onTap,
            scrollController: scrollController,
            tags: tagSearchController.suggests.toList(),
            reverse: true,
          );
        case false:
          return const Center();
      }
    });
  }
}
