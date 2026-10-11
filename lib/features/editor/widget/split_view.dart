import 'package:get/get.dart';
import 'package:niku/namespace.dart' as n;
import 'package:flutter/material.dart';
import 'package:hydit/utils/utils.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hydit/entities/tag.dart';
import 'package:hydit/services/relations.dart';
import 'package:hydit/widgets/lists/tag_list.dart';
import 'package:hydit/features/search/getx/tag_search.dart';

import '../getx/base.dart';


class Up extends HookWidget {
  final String tag;
  final List<Tag> tags;

  const Up({super.key, required this.tag, required this.tags});

  Color? background(TagState state) => switch (state) {
    .added => addition,
    .removed => deletion,
    .unchanged => null,
  };

  TagManager get manager => Get.find(tag: tag);

  TagRelationService get rel => Get.find();

  Tag? idealTag(Tag tag) => rel.ideal(tag: tag, key: manager.key);

  List<Tag> ancestors(Tag tag) => rel.ancestors(tag: tag, key: manager.key);

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

            final bg = background(state);

            final ideal = idealTag(tag);

            final anc = ancestors(tag);

            return TagTile(
              tag: tag,
              ideal: ideal,
              background: bg,
              onTap: manager.toggle,
              onLongPress: Tag.toClipboard,
              contentPadding: const .fromLTRB(16, 0, 4, 0),
              trailing: Row(
                mainAxisSize: .min,
                spacing: 8,
                children: [
                  if (manager.files.length > 1)
                    TagCount(
                      tag: tag,
                      count: manager.count(tag),
                    ),

                  TagTilePopup(
                    tag: tag,
                    ancestors: anc,
                    ideal: ideal,
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }
}

class const TagTilePopup ({
  super.key,
  required final Tag tag,
  final Tag? ideal,
  final List<Tag> ancestors = const [],
}) extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final ideal = this.ideal;

    return PopupMenuButton(
      icon: Badge(
        isLabelVisible: ancestors.isNotEmpty,
        child: const Icon(Icons.more_vert),
      ),
      itemBuilder: (context) => [
        if (ancestors.isNotEmpty)
          PopupMenuItem(
            child: ''
                '${ancestors.length} ancestor'
                '${ancestors.length > 1 ? 's' : ''}'.n,
            onTap: () => showModalTagSheet(context, ancestors),
          ),

        PopupMenuItem(
          child: const Text('copy tag'),
          onTap: () => Tag.toClipboard(tag),
        ),

        if (ideal != null && ideal != tag)
          PopupMenuItem(
            child: const Text('copy ideal tag'),
            onTap: () => Tag.toClipboard(ideal),
          ),
      ],
    );
  }
}


void showModalTagSheet(BuildContext context, List<Tag> ancestors) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.25,
        initialChildSize: 0.5,
        maxChildSize: 0.5,
        snap: true,
        builder: (context, scrollController) {
          return SafeArea(
            child: TagList(
              tags: ancestors,
              shrinkWrap: true,
              scrollController: scrollController,
              itemBuilder: (context, tag) {
                return TagTile(
                  tag: tag,
                  onTap: Tag.toClipboard,
                );
              },
            ),
          );
        },
      );
    },
  );
}


class Down extends HookWidget {
  final String tag;

  const Down({super.key, required this.tag});

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
