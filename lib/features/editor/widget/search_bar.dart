import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/features/search/getx/tag_search.dart';
import 'package:hydit/features/search/widget/search.dart';
import 'package:hydit/features/search/widget/tag_actions.dart';

import '../getx/base.dart';


class EditorTagSearchBar extends StatelessWidget {
  final String tag;

  const EditorTagSearchBar({super.key, required this.tag});

  TagManager get manager => Get.find();
  TagSearchController get tagSearch => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) => Obx(() {
    return TagSearchBar(
      enabled: manager.editable,
      hintText: manager.editable
          ? 'Add tags'
          : 'Service is read-only',
      onSubmitted: null,
      tagSearchController: tagSearch,
      actions: TagActions(
        onClear: tagSearch.clear,
        onInsert: () {
          manager.addRaw(tagSearch.text);
          tagSearch.clear();
        },
      ),
    );
  });
}
