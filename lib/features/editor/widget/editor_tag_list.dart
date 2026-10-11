import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/widgets/tag.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/services/relations.dart';

import '../getx/base.dart';


class EditorTagList extends HookWidget {
  final String tag;
  final List<Tag> tags;

  const EditorTagList({super.key, required this.tag, required this.tags});

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
