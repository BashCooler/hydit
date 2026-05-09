import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/extra/extra.dart';
import 'package:niku/namespace.dart' as n;
import 'package:filesize/filesize.dart';

import 'package:hydrus_flutter/core/domain/di/images.dart';
import 'package:hydrus_flutter/features/viewer/getx/page.dart';

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
          return Column(
            spacing: 5,
            mainAxisAlignment: .center,
            crossAxisAlignment: .start,
            children: <Widget>[
              buildDiff(manager),
              buildService(context, manager),
              switch (mode) {
                Mode.paged => buildMeta(context, tag),
                Mode.batch => const SizedBox.shrink(),
              },
            ],
          );
        },
      ),
    );
  }
}


extension Builders on Info
{
  Widget buildMeta(BuildContext context, String tag) {
    final Images images = Get.find();
    final PageGetxController page = Get.find(tag: tag);
    final image = images[page.i];

    return 'id: ${image.id} / ${filesize(image.size)} / ${image.res}'.n
      ..labelMedium
      ..maxLines = 2;
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
        '${manager.count} tags'.n
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
