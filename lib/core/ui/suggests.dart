import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydrus_flutter/core/domain/entities.dart';

import 'package:hydrus_flutter/utils/theme.dart';
import 'package:hydrus_flutter/features/gallery/getx/query.dart';


const additions = Color(0x333fb950);
const deletions = Color(0x33f85149);


class Suggests extends StatelessWidget {
  final Widget? trailing;
  final bool expanded;
  final ScrollController? scrollController;
  final void Function(Tag tag) onTap;

  const Suggests({
    super.key,
    this.expanded = true,
    this.scrollController,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QueryController>();
    return Obx(() {
      if (!controller.suggestsVisible) {
        return const Hint();
      }
      return TagList(
        trailing: trailing,
        onTap: onTap,
        scrollController: scrollController,
        tags: controller.suggests);
    });
  }
}


class Hint extends StatelessWidget {
  const Hint({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: .bottomCenter,
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: .only(bottom: 45),
          child: Column(
            mainAxisAlignment: .center,
            spacing: 15,
            children: [
              Icon(Icons.search, size: 96),
              Text('Start typing to search tags'),
            ],
          ),
        ),
      ),
    );
  }
}


/// [ListView] of [Tag]s.
///
/// The [tags] should be of type [RxList] or [RxSet] and should
/// contain [Tag]s.
///
/// Parameters [trailing] and [onTap] apply to each [ListTile] in
/// [ListView].
///
/// Default [trailing] is [Tag.count].
///
/// The [onTap] method is called when [ListTile] pressed and
/// usually used to add tag to some [RxList] or [RxSet].
class TagList extends StatelessWidget {
  final Widget? trailing;
  final dynamic tags;
  final ScrollController? scrollController;
  final void Function(Tag tag)? onTap;

  const TagList({
    super.key,
    this.trailing,
    this.onTap,
    this.scrollController,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: Scrollbar(
          controller: scrollController,
          child:  ListView.builder(
            padding: .zero,
            reverse: true,
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

    final Icon? icon;
    final Color? tileColor;

    switch (tag.diff) {
      case .add:
        icon = Icon(Icons.playlist_remove);
        tileColor = additions;
      case .delete:
        icon = Icon(Icons.undo);
        tileColor = deletions;
      case _:
        icon = null;
        tileColor = null;
    }

    return ListTile(
      enabled: onTap != null,
      tileColor: tileColor,
      minTileHeight: AppTheme.fieldHeight,
      title: Text(tag.pretty, style: TextStyle(color: color)),
      trailing: icon ?? trailing ?? Text(
        tag.count?.toString() ?? '0',
        style: TextStyle(color: color, fontSize: 14.0),
      ),
      onTap: () => onTap?.call(tag),
    );
  }
}
