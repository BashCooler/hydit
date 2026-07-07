import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/entities/tag.dart';


/// Parameters [trailing] and [onTap] apply to each [ListTile] in
/// [ListView].
///
/// Default [trailing] is [Tag.count].
class TagList extends StatelessWidget {
  final List<Tag> tags;
  final ScrollController? scrollController;
  final bool reverse;
  final Widget Function(BuildContext context, Tag tag) itemBuilder;

  const TagList({
    super.key,
    this.scrollController,
    required this.tags,
    this.reverse = false,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Scrollbar(
          controller: scrollController,
          child: ListView.builder(
            reverse: reverse,
            itemCount: tags.length,
            controller: scrollController,
            itemBuilder: (context, index) {
              return itemBuilder(context, tags[index]);
            },
          ),
        ),
      ),
    );
  }
}


class TagTile extends StatelessWidget {
  final bool enabled;
  final Tag tag;
  final Color? background;
  final Widget? trailing;
  final void Function(Tag tag)? onTap;
  final void Function(Tag tag)? onLongPress;

  const TagTile({
    super.key,
    this.enabled = true,
    required this.tag,
    this.background,
    this.trailing,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: enabled,
      onTap: () => onTap?.call(tag),
      onLongPress: () => onLongPress?.call(tag),
      tileColor: background,
      minTileHeight: 55,
      title: tag.pretty.n
        ..color = tag.color,
      trailing: trailing,
    );
  }
}

