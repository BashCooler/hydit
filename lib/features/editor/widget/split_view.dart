import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:multi_split_view/multi_split_view.dart';

import 'package:hydit/core/ui/tag_list.dart';
import 'package:hydit/features/search/widget/suggests.dart';

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


class Up extends HookWidget {
  const Up({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollUp = useScrollController();

    return GetBuilder(
      init: Get.find<TagManager>(),
      builder: (manager) {
        switch (manager.loading) {
          case true:
            return Skeletonizer(
              child: ListView.builder(
                reverse: true,
                itemCount: 20,
                controller: scrollUp,
                itemBuilder: (context, index) {
                  return ListTile(title: Text('X' * 16));
                },
              ),
            );
          case false:
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
        }
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
        final icon = manager.editable
            ? Icons.add
            : Icons.lock_outline;
        return Skeletonizer(
          enabled: manager.loading,
          child: Suggests(
            tag: tag,
            trailing: Skeleton.ignore(child: Icon(icon)),
            onTap: manager.editable
                ? manager.add
                : null,
          ),
        );
      },
    );
  }
}