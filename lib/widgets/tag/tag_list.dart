import 'package:flutter/material.dart';

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
  //
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
