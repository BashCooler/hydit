import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/reactive/file.dart';
import 'package:hydit/reactive/file_store.dart';

import 'info.dart';
import 'preview_grid.dart';
import '../getx/base.dart';


class EditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String tag;
  final double toolbarHeight;

  const EditorAppBar({
    super.key,
    required this.tag,
    this.toolbarHeight = 100,
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
          Info(tag: tag),
          SizedBox.square(
            dimension: toolbarHeight,
            child: PreviewGrid(tag: tag),
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

  const Info({super.key, required this.tag});

  FileStore get files => Get.find(tag: tag);
  TagManager get manager => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 200,
        maxHeight: 100,
      ),
      child: Obx(() {

        return Column(
          spacing: 5,
          mainAxisAlignment: .center,
          crossAxisAlignment: .start,
          children: [
            Row(
              children: [
                '${manager.current.length} tags'.n
                  ..fontSize = 16,
                Diff(tag: tag),
              ],
            ),
            buildFileCount(manager),
          ],
        );
      }),
    );
  }

  Widget buildFileCount(TagManager manager) {
    return 'Editing ${manager.fileCount} files'.n..labelMedium;
  }

  Widget buildMeta(HydrusFile file) {
    return 'id: ${file.id}, ${file.meta.size},\n${file.meta.res}'.n
      ..labelMedium
      ..maxLines = 2;
  }
}
