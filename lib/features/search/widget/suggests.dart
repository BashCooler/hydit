import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/entities/tag.dart';
import 'package:hydit/widgets/tag_list.dart';

import '../getx/search.dart';


class Suggests extends StatelessWidget {
  final ScrollController? scrollController;
  final TagSearchController tagSearchController;
  final Widget Function(BuildContext context, Tag tag) itemBuilder;

  const Suggests({
    super.key,
    this.scrollController,
    required this.tagSearchController,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (tagSearchController.suggestsVisible) {
        case true:
          return TagList(
            tags: tagSearchController.suggests.toList(),
            scrollController: scrollController,
            reverse: true,
            itemBuilder: itemBuilder,
          );
        case false:
          return const Center();
      }
    });
  }
}
