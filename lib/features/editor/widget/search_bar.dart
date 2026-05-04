import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydrus_flutter/core/domain/entities.dart';

import 'package:hydrus_flutter/features/search/getx/query.dart';
import 'package:hydrus_flutter/features/search/widget/search.dart';

import '../getx/tags.dart';


class EditorTagSearchBar extends StatelessWidget {
  final String tag;

  const EditorTagSearchBar({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final TagManager manager = Get.find();

    return Obx(() {
      return TagSearchBar(
        enabled: manager.editable,
        hintText: manager.editable
            ? 'Add tags to ${manager.service}'
            : 'Read-only service selected',
        onSubmitted: null,
        actions: EditorTagSearchBarActions(tag: tag),
        tag: tag,
      );
    });
  }
}


class EditorTagSearchBarActions extends StatelessWidget {
  final String tag;

  const EditorTagSearchBarActions({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final QueryController query = Get.find(tag: tag);
    return Row(
      mainAxisSize: .min,
      spacing: 5,
      mainAxisAlignment: .end,
      children: [
        IconButton(
          onPressed: query.clear,
          icon: const Icon(Icons.clear),
          tooltip: 'Clear',
        ),
        IconButton(
          onPressed: () {
            Get.find<TagManager>().add(Tag(query.text));
            query.clear();
          },
          icon: const Icon(Icons.arrow_drop_up),
          tooltip: 'Insert input as tag',
        ),
        const VerticalDivider(width: 0),
      ],
    );
  }
}