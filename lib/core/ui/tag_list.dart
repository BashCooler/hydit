import 'package:flutter/material.dart';
import 'package:hydit/utils/theme.dart';
import '../domain/entities.dart';


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

  const TagList({
    super.key,
    this.trailing,
    this.onTap,
    this.scrollController,
    required this.tags,
    this.reverse = false,
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
            itemBuilder: (_, index) => SearchEntry(
              index: index,
              tags: tags,
              trailing: trailing,
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }
}

class SearchEntry extends StatelessWidget {
  final int index;
  final Widget? trailing;
  final dynamic tags;
  final void Function(Tag tag)? onTap;

  const SearchEntry({
    super.key,
    required this.index,
    this.trailing,
    required this.onTap,
    this.tags,
  });

  @override
  Widget build(BuildContext context) {
    final tag = tags[index] as Tag;
    final color = namespaceColors[tag.namespace] ?? namespaceColors['_'];

    return ListTile(
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