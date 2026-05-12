import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydrus_flutter/core/domain/entities.dart';
import 'package:niku/extra/extra.dart';
import 'package:niku/namespace.dart' as n;
import 'package:filesize/filesize.dart';

import 'package:hydrus_flutter/core/domain/file_repo.dart';
import 'package:hydrus_flutter/features/viewer/getx/page.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../getx/tags.dart';
import '../page/editor.dart';


class EditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double toolbarHeight;
  final String tag;
  final Widget? child;
  final GestureTapCallback? onTap;
  final Mode mode;

  const EditorAppBar({
    super.key,
    required this.toolbarHeight,
    required this.tag,
    this.child,
    this.onTap,
    required this.mode,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 200,
        maxHeight: 100,
      ),
      child: GetBuilder(
        init: Get.find<TagManager>(),
        builder: (manager) {
          final FileRepo files = Get.find(tag: tag);
          final PageGetxController page = Get.find(tag: tag);
          final file = files[page.i];
          return Obx(() {
            return Skeletonizer(
              enabled: manager.loading,
              child: Column(
                spacing: 5,
                mainAxisAlignment: .center,
                crossAxisAlignment: .start,
                children: <Widget>[
                  buildDiff(manager),
                  buildService(context, manager),
                  switch (mode) {
                    Mode.paged => buildMeta(file),
                    Mode.batch => buildFileCount(manager),
                  },
                ],
              ),
            );
          });
        },
      ),
    );
  }
}


extension Builders on Info
{
  Widget buildMeta(HydrusFile file) {
    return 'id: ${file.id}, ${filesize(file.size)},\n${file.res}'.n
      ..labelMedium
      ..maxLines = 2;
  }

  Widget buildFileCount(TagManager manager) {
    return 'Editing ${manager.fileCount} files'.n..labelMedium;
  }

  Widget buildService(BuildContext context, TagManager manager) {
    return 'service: ${manager.service}'.n
      ..labelMedium
      ..maxLines = 1
      ..overflow = .ellipsis;
  }

  Widget buildDiff(TagManager manager) {
    return Row(
      crossAxisAlignment: .center,
      children: [
        '${manager.tagCount} tags'.n
          ..fontSize = 16,
        const VerticalDivider(width: 8),
        buildAdditions(manager),
        buildDeletions(manager),
      ],
    );
  }

  Widget buildAdditions(TagManager manager) {
    switch (manager.additionsCount) {
      case > 0:
        return n.Row([
          '+${manager.additionsCount}'.n
            ..fontSize = 16
            ..color = additions,
          const VerticalDivider(width: 6),
        ]);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget buildDeletions(TagManager manager) {
    switch (manager.deletionsCount) {
      case > 0:
        return '-${manager.deletionsCount}'.n
          ..fontSize = 16
          ..color = deletions;
      default:
        return const SizedBox.shrink();
    }
  }
}
