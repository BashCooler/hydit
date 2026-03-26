import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydrus_flutter/core/logic/entities.dart';

import 'package:hydrus_flutter/utils/theme.dart';
import 'package:hydrus_flutter/features/gallery/getx/query.dart';


const additions = Color(0xFF3fb950);
const deletions = Color(0xFFf85149);


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
        return const _Hint();
      }
      return TagList(
        trailing: trailing,
        onTap: onTap,
        scrollController: scrollController,
        observable: controller.suggests);
    });
  }
}


/// [ListView] of [Tag]s.
///
/// The [observable] should be of type [RxList] or [RxSet] and should
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
  final dynamic observable;
  final ScrollController? scrollController;
  final void Function(Tag tag) onTap;

  const TagList({
    super.key,
    this.trailing,
    required this.onTap,
    this.scrollController,
    required this.observable,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: Scrollbar(
        controller: scrollController,
        child: Obx(() => ListView.builder(
          reverse: true,
          itemCount: observable.length,
          controller: scrollController,
          itemBuilder: (_, index) => _SearchEntry(
            index: index,
            observable: observable,
            trailing: trailing,
            onTap: onTap,
          ),
        )),
      ),
    );
  }
}

class _SearchEntry extends StatelessWidget {
  final int index;
  final Widget? trailing;
  final dynamic observable;
  final void Function(Tag tag) onTap;

  const _SearchEntry({
    required this.index,
    this.trailing,
    required this.onTap,
    this.observable,
  });

  @override
  Widget build(BuildContext context) {
    final tag = observable[index] as Tag;
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
      tileColor: tileColor,
      minTileHeight: AppTheme.fieldHeight,
      title: Text(tag.value, style: TextStyle(color: color)),
      trailing: icon ?? trailing ?? Text(
        tag.count?.toString() ?? '0',
        style: TextStyle(color: color, fontSize: 14.0),
      ),
      onTap: () => onTap.call(tag),
    );
  }
}


class _Hint extends StatelessWidget {
  const _Hint();

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
