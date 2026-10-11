import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hydit/widgets/tag.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/features/search/getx/tag_search.dart';
import 'package:hydit/features/search/widget/search.dart';
import 'package:hydit/features/search/widget/tag_actions.dart';

import '../getx/base.dart';


class const EditorTagSearchBar({
  super.key,
  required final String tag,
}) extends StatelessWidget {
  //
  TagManager get manager => Get.find(tag: tag);

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


class const EditorSuggests({
  super.key,
  required final String tag,
}) extends HookWidget {
  //
  TagManager get manager => Get.find(tag: tag);

  TagSearchController get search => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    final scroll = useScrollController();

    return Obx(
      () => TagList(
        reverse: true,
        tags: search.suggests.toList(),
        scrollController: scroll,
        itemBuilder: (context, tag) {
          return TagTile(
            tag: tag,
            onTap: manager.add,
            onLongPress: Tag.toClipboard,
            trailing: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}
