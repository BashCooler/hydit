import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/utils/theme.dart';
import 'package:hydit/entities/tag.dart';


class const TagList({
  super.key,
  final ScrollController? scrollController,
  required final List<Tag> tags,
  final bool reverse = false,
  final bool shrinkWrap = false,
  required final Widget Function(BuildContext context, Tag tag) itemBuilder,
}) extends StatelessWidget {

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
            shrinkWrap: shrinkWrap,
            padding: Insets.listPadding,
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
  final Tag? _ideal;
  final Color? background;
  final Widget? trailing;
  final void Function(Tag tag)? onTap;
  final void Function(Tag tag)? onLongPress;
  final EdgeInsetsGeometry? contentPadding;

  const TagTile({
    super.key,
    this.enabled = true,
    required this.tag,
    this._ideal,
    this.background,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.contentPadding,
  });

  Tag? get ideal => _ideal != null && _ideal != tag ? _ideal : null;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: .hardEdge,
      child: ListTile(
        enabled: enabled,
        onTap: () => onTap?.call(tag),
        onLongPress: () => onLongPress?.call(tag),
        tileColor: background,
        minTileHeight: Sizes.minTileHeight,
        contentPadding: contentPadding,
        title: Text.rich(
          TextSpan(
            children: [
              tag.toSpan(),
              ?ideal?.toSpan(prefix: ' ➔ '),
            ],
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}


class const TagCount ({
  super.key,
  required final Tag tag,
  required final int count,
}) extends StatelessWidget {

  @override
  Widget build(BuildContext context) => '$count'.n
    ..color = tag.color
    ..fontSize = 14;
}


extension TagTextSpan on Tag {
  TextSpan toSpan({String? prefix}) => TextSpan(
    text: prefix == null ? pretty : '$prefix$pretty',
    style: TextStyle(color: color),
  );
}
