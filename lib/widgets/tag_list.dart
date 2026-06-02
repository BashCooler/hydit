import 'package:flutter/material.dart';

import 'package:hydit/utils/theme.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/features/editor/getx/tags.dart';


/// Parameters [trailing] and [onTap] apply to each [ListTile] in
/// [ListView].
///
/// Default [trailing] is [Tag.count].
class TagList extends StatelessWidget {
  final Widget? trailing;
  final List<Tag> tags;
  final ScrollController? scrollController;
  final void Function(Tag tag)? onTap;
  final bool reverse;
  final TagManager? manager;

  const TagList({
    super.key,
    this.trailing,
    this.onTap,
    this.scrollController,
    required this.tags,
    this.reverse = false,
    this.manager,
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
          child:  ListView.builder(
            reverse: reverse,
            itemCount: tags.length,
            controller: scrollController,
            itemBuilder: (_, index) => TagListEntry(
              tag: tags[index],
              trailing: trailing,
              onTap: onTap,
              manager: manager,
            ),
          ),
        ),
      ),
    );
  }
}


class TagListEntry extends StatelessWidget {
  final Widget? trailing;
  final Tag tag;
  final void Function(Tag tag)? onTap;
  final TagManager? manager;

  const TagListEntry({
    super.key,
    this.trailing,
    required this.onTap,
    required this.tag,
    this.manager,
  });

  @override
  Widget build(BuildContext context) {
    final color = namespaceColors[tag.namespace] ?? namespaceColors['_'];

    final TagState? state = manager?.stateOf(tag);
    final Color? tileColor = switch (state) {
      TagState.added => AppColors.addition,
      TagState.removed => AppColors.deletion,
      _ => null,
    };

    return ListTile(
      tileColor: tileColor,
      enabled: onTap != null,
      minTileHeight: AppTheme.fieldHeight,
      title: Text(tag.pretty, style: TextStyle(color: color)),
      trailing: trailing ?? Text(
        tag.count?.toString() ?? '',
        style: TextStyle(color: color, fontSize: 14.0),
      ),
      onTap: () => onTap?.call(tag),
    );
  }
}
