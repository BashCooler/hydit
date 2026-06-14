import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:multi_split_view/multi_split_view.dart';

import 'package:hydit/utils/theme.dart';
import 'package:hydit/widgets/tag_list.dart';
import 'package:hydit/features/search/getx/search.dart';
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

  Color? background(TagState state) => switch (state) {
    .added => AppColors.addition,
    .removed => AppColors.deletion,
    .unchanged => null,
  };

  IconData icon(bool editable, TagState state) => switch (editable) {
    false => Icons.lock_outline,
    true => switch (state) {
      .removed => Icons.undo,
      _ => Icons.playlist_remove,
    },
  };

  @override
  Widget build(BuildContext context) {
    final scroll = useScrollController();

    return GetBuilder(
      init: Get.find<TagManager>(),
      builder: (manager) {
        switch (manager.loading) {
          case true:
            return Skeletonizer(
              child: ListView.builder(
                reverse: true,
                itemCount: 20,
                controller: scroll,
                itemBuilder: (context, index) {
                  return ListTile(title: Text('X' * 16));
                },
              ),
            );
          case false:
            return TagList(
              tags: manager.tags().toList(),
              scrollController: scroll,
              reverse: true,
              itemBuilder: (context, tag) {
                final state = manager.stateOf(tag);
                return TagTile(
                  tag: tag,
                  onTap: manager.editable ? manager.remove : null,
                  background: background(state),
                  trailing: Icon(icon(manager.editable, state)),
                );
              },
            );
        }
      },
    );
  }
}


class Down extends HookWidget {
  final String tag;

  const Down({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final scroll = useScrollController();
    final TagSearchController tagSearch = Get.find(tag: tag);

    return GetBuilder(
      init: Get.find<TagManager>(),
      builder: (manager) {
        final icon = manager.editable
            ? Icons.add
            : Icons.lock_outline;
        return Skeletonizer(
          enabled: manager.loading,
          child: Suggests(
            scrollController: scroll,
            tagSearchController: tagSearch,
            itemBuilder: (context, tag) => TagTile(
              tag: tag,
              onTap: manager.editable ? manager.add : null,
              trailing: Skeleton.ignore(child: Icon(icon)),
            ),
          ),
        );
      },
    );
  }
}