import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:hydrus_flutter/core/ui/tag_list.dart';
import 'package:hydrus_flutter/core/domain/entities.dart';

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
      if (!controller.suggestsVisible) {
        return const Hint();
      }
      return TagList(
        trailing: trailing,
        onTap: onTap,
        scrollController: scrollController,
        tags: controller.suggests,
        reverse: true,
      );
    });
  }
}


class Hint extends StatelessWidget {
  const Hint({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: .bottomCenter,
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: .only(bottom: 45),
          child: Skeleton.keep(
            child: Column(
              mainAxisAlignment: .center,
              spacing: 15,
              children: [
                Icon(Icons.search, size: 96),
                Text('Start typing to search tags'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
