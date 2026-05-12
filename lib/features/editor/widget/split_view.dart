import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:multi_split_view/multi_split_view.dart';

import 'package:hydrus_flutter/core/ui/tag_list.dart';
import 'package:hydrus_flutter/features/search/widget/suggests.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../getx/tags.dart';


class EditorSplitView extends HookWidget {
  final String tag;

  const EditorSplitView({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final areas = [
      Area(min: 0, flex: 1.4, max: 2.375, builder: (_, area) => Up()),
      Area(flex: 1, builder: (_, area) => Down(tag: tag)),
    ];

    final controller = useMemoized(() {
      return MultiSplitViewController(areas: areas);
    });

    return Expanded(
      child: MultiSplitView(
        axis: .vertical,
        resizable: true,
        controller: controller,
        dividerBuilder: (_, _, _, drag, hover, _) {
          return Container(color: Get.theme.dividerColor);
        },
      ),
    );
  }
}


class Up extends StatelessWidget {
  final scrollUp = ScrollController();

  Up({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: Get.find<TagManager>(),
      builder: (manager) {
        return TagList(
          tags: manager.tags,
          trailing: Icon(manager.editable
              ? Icons.playlist_remove
              : Icons.lock_outline),
          scrollController: scrollUp,
          onTap: manager.editable
              ? manager.delete
              : null,
          reverse: true,
        );
      },
    );
  }
}


class Down extends StatelessWidget {
  final String tag;

  const Down({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: Get.find<TagManager>(),
      builder: (manager) {
        return Suggests(
          tag: tag,
          trailing: Icon(manager.editable
              ? Icons.add
              : Icons.lock_outline),
          onTap: manager.editable
              ? manager.add
              : null,
        );
      },
    );
  }
}