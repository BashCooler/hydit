import 'package:flutter/material.dart';

import 'package:hydit/entities/tag.dart';

import 'tag_list.dart';
import 'tag_tile.dart';


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
