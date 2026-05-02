import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydrus_flutter/core/domain/entities.dart';

import 'package:hydrus_flutter/core/ui/search.dart';
import 'package:hydrus_flutter/features/gallery/getx/query.dart';

import '../getx/tags.dart';


class EditorTagSearchBar extends StatelessWidget {
  const EditorTagSearchBar({super.key});

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
        actions: const EditorTagSearchBarActions(),
        tag: 'Editor',
      );
    });
  }
}


class EditorTagSearchBarActions extends StatelessWidget {
  const EditorTagSearchBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    final query = Get.find<QueryController>();
    return Row(
      mainAxisSize: .min,
      spacing: 5.0,
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
        const VerticalDivider(width: 0.0),
      ],
    );
  }
}