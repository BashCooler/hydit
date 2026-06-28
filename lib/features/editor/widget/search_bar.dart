import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:hydit/features/search/getx/search.dart';
import 'package:hydit/features/search/widget/search.dart';
import 'package:hydit/features/search/widget/tag_actions.dart';

import '../getx/tags.dart';


class EditorTagSearchBar extends StatelessWidget {
  final String tag;

  const EditorTagSearchBar({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final TagManager manager = Get.find();
    final TagSearchController tagSearch = Get.find(tag: tag);

    return Obx(() {
      return Skeletonizer(
        enabled: manager.loading,
        child: TagSearchBar(
          enabled: manager.editable,
          hintText: manager.editable
              ? 'Add tags'
              : 'Service is read-only',
          onSubmitted: null,
          tagSearchController: tagSearch,
          actions: Skeleton.shade(
            child: TagActions(
              onClear: tagSearch.clear,
              onInsert: () {
                manager.addRaw(tagSearch.text);
                tagSearch.clear();
              },
            ),
          ),
        ),
      );
    });
  }
}
