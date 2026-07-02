import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hydit/utils/theme.dart';
import 'package:hydit/widgets/tag_list.dart';
import 'package:hydit/features/search/getx/tag_search.dart';
import 'package:hydit/features/search/widget/suggests.dart';

import '../getx/manager.dart';


class Up extends HookWidget {
  const Up({super.key});

  Color? background(TagState state) => switch (state) {
    .added => addition,
    .removed => deletion,
    .unchanged => null,
  };

  IconData icon(bool editable, TagState state) => switch (editable) {
    false => Icons.lock_outline,
    true => switch (state) {
      .removed => Icons.undo,
      _ => Icons.playlist_remove,
    },
  };

  TagManager get manager => Get.find();

  @override
  Widget build(BuildContext context) {
    final scroll = useScrollController();

    return Expanded(
      child: Obx(() {

        return TagList(
          tags: manager.tags(),
          scrollController: scroll,
          reverse: true,
          itemBuilder: (context, tag) {
            final state = manager.state(tag);
            return TagTile(
              tag: tag,
              onTap: manager.editable ? manager.remove : null,
              background: background(state),
              trailing: Icon(icon(manager.editable, state)),
            );
          },
        );
      }),
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

    return Obx(() {
      final icon = manager.editable
          ? Icons.add
          : Icons.lock_outline;
      return Suggests(
        scrollController: scroll,
        tagSearchController: tagSearch,
        itemBuilder: (context, tag) => TagTile(
          tag: tag,
          onTap: manager.editable ? manager.add : null,
          trailing: Icon(icon),
        ),
      );
    });
  }
}
