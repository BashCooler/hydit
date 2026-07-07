import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/utils/utils.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hydit/entities/tag.dart';
import 'package:hydit/widgets/tag_list.dart';
import 'package:hydit/features/search/getx/tag_search.dart';
import 'package:hydit/features/search/widget/suggests.dart';

import '../getx/base.dart';


class Up extends HookWidget {
  final List<Tag> tags;

  const Up({super.key, required this.tags});

  Color? background(TagState state) => switch (state) {
    .added => addition,
    .removed => deletion,
    .unchanged => null,
  };

  IconData icon(bool editable, TagState state) {
    return switch (state) {
      TagState.removed => Icons.undo,
      _ => Icons.playlist_remove,
    };
  }

  TagManager get manager => Get.find();

  @override
  Widget build(BuildContext context) {
    final scroll = useScrollController();

    return Expanded(
      child: TagList(
        tags: tags,
        scrollController: scroll,
        reverse: true,
        itemBuilder: (context, tag) {
          return Obx(() {
            final state = manager.state(tag);

            return TagTile(
              tag: tag,
              onTap: manager.editable ? manager.remove : null,
              onLongPress: copyTag,
              background: background(state),
              trailing: Row(
                mainAxisSize: .min,
                spacing: 20,
                children: [
                  if (manager.fileCount > 1)
                    TagCount(tag: tag, count: manager.count(tag)),

                  if (manager.editable)
                    Icon(icon(manager.editable, state)),
                ],
              ),
            );
          });
        },
      ),
    );
  }
}


class Down extends HookWidget {
  final String tag;

  const Down({super.key, required this.tag});

  TagManager get manager => Get.find();
  TagSearchController get tagSearch => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    final scroll = useScrollController();

    return Suggests(
      scrollController: scroll,
      tagSearchController: tagSearch,
      itemBuilder: (context, tag) => TagTile(
        tag: tag,
        onTap: manager.add,
        onLongPress: copyTag,
        trailing: const Icon(Icons.add),
      ),
    );
  }
}
