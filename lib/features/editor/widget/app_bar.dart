import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:skeletonizer/skeletonizer.dart';

import 'package:hydit/entities/tag.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/viewer/getx/page.dart';

import '../getx/tags.dart';
import '../page/editor.dart';


class EditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String tag;
  final double toolbarHeight;
  final GestureTapCallback? onTap;
  final Mode mode;
  final Widget? child;

  const EditorAppBar({
    super.key,
    required this.tag,
    this.toolbarHeight = 100,
    required this.mode,
    this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 2,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      toolbarHeight: toolbarHeight,
      title: Row(
        crossAxisAlignment: .center,
        mainAxisAlignment: .spaceBetween,
        children: [
          Info(tag: tag, mode: mode),
          GestureDetector(
            onTap: onTap,
            child: SizedBox(
              width: 100,
              height: 100,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}


class Info extends StatelessWidget {
  final String tag;
  final Mode mode;

  const Info({super.key, required this.tag, required this.mode});

  TagManager get manager => Get.find();
  FileStore get files => Get.find(tag: tag);
  PageGetxController get page => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 200,
        maxHeight: 100,
      ),
      child: Obx(() {
        final file = files[page.i];
        return Skeletonizer(
          enabled: manager.loading,
          child: Column(
            spacing: 5,
            mainAxisAlignment: .center,
            crossAxisAlignment: .start,
            children: [
              buildDiff(manager),
              buildService(context, manager),
              switch (mode) {
                Mode.paged => buildMeta(file),
                Mode.batch => buildFileCount(manager),
              },
            ],
          ),
        );
      }),
    );
  }
}


extension Builders on Info
{
  Widget buildFileCount(TagManager manager) {
    return 'Editing ${manager.fileCount} files'.n..labelMedium;
  }

  Widget buildDiff(TagManager manager) {
    return Row(
      crossAxisAlignment: .center,
      children: [
        '${manager.lengthOf()} tags'.n
          ..fontSize = 16,
        const VerticalDivider(width: 8),
        buildAdditions(manager),
        buildDeletions(manager),
      ],
    );
  }

  Widget buildAdditions(TagManager manager) {
    final count = manager
        .additions
        .of(manager.service)
        .length;
    switch (count) {
      case > 0:
        return n.Row([
          '+$count'.n
            ..fontSize = 16
            ..color = additions,
          const VerticalDivider(width: 6),
        ]);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget buildDeletions(TagManager manager) {
    final count = manager
        .deletions
        .of(manager.service)
        .length;
    switch (count) {
      case > 0:
        return '-$count'.n
          ..fontSize = 16
          ..color = deletions;
      default:
        return const SizedBox.shrink();
    }
  }

  Widget buildService(BuildContext context, TagManager manager) {
    return 'service: ${manager.service}'.n
      ..labelMedium
      ..maxLines = 1
      ..overflow = .ellipsis;
  }

  Widget buildMeta(HydrusFile file) {
    return 'id: ${file.id}, ${file.meta!.size},\n${file.meta!.res}'.n
      ..labelMedium
      ..maxLines = 2;
  }
}
