import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:filesize/filesize.dart';

import 'package:hydrus_flutter/core/ui/images.dart';
import 'package:hydrus_flutter/core/domain/di/images.dart';
import 'package:hydrus_flutter/features/viewer/getx/page.dart';
import 'package:hydrus_flutter/features/editor/page/preview.dart';
import 'package:hydrus_flutter/features/viewer/widget/views.dart';

import '../getx/tags.dart';
import '../page/editor.dart';


class EditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double toolbarHeight;
  final String tag;

  const EditorAppBar({
    super.key,
    required this.toolbarHeight,
    required this.tag,
  });

  void openPreview(int index) {
    Get.to(() => Preview(index: index, tag: tag),
      transition: .fadeIn,
      curve: Curves.easeInCubic,
      opaque: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Images images = Get.find();
    final PageGetxController page = Get.find(tag: tag);

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
          GestureDetector(
            onTap: () => openPreview(page.i),
            child: SizedBox(
              width: 100,
              height: 100,
              child: Obx(() {
                return ObxHero(
                  index: page.i,
                  heroTag: images[page.i].id,
                  getTag: tag,
                  child: Thumbnail(images[page.i]),
                );
              }),
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

  const Info({super.key, required this.tag});

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
              buildMeta(context, tag),
            ],
          );
        },
      ),
    );
  }
}


extension Builders on Info
{
  Text buildMeta(BuildContext context, String tag) {
    final Images images = Get.find();
    final PageGetxController page = Get.find(tag: tag);
    final image = images[page.i];

    return Text("id: ${image.id} / "
        "${filesize(image.size)} / "
        "${image.res}",
      style: Theme
          .of(context)
          .textTheme
          .labelMedium,
      maxLines: 2,
    );
  }

  Text buildService(BuildContext context, TagManager manager) {
    return Text("service: ${manager.service}",
      style: Theme
          .of(context)
          .textTheme
          .labelMedium,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  DefaultTextStyle buildDiff(TagManager manager) {
    return DefaultTextStyle(
      style: const TextStyle(fontSize: 16),
      child: Row(
        crossAxisAlignment: .center,
        children: [
          Text("${manager.count} tags"),
          const VerticalDivider(width: 8),
          buildAdditions(manager),
          buildDeletions(manager),
        ],
      ),
    );
  }

  Widget buildAdditions(TagManager manager) {
    switch (manager.additionsCount) {
      case > 0:
        return Row(
          children: [
            Text(
              "+${manager.additionsCount}",
              style: const .new(color: additions),
            ),
            const VerticalDivider(width: 6),
          ],
        );
      default:
        return SizedBox.shrink();
    }
  }

  Widget buildDeletions(TagManager manager) {
    switch (manager.deletionsCount) {
      case > 0:
        return Text(
          "-${manager.deletionsCount}",
          style: const .new(color: deletions),
        );
      default:
        return SizedBox.shrink();
    }
  }
}
