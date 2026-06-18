import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/features/gallery/getx/selection.dart';
import 'package:hydit/features/search/widget/sorting.dart';
import 'package:niku/extra/primitive.dart';

import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/search/getx/query.dart';


const shadows = [
  Shadow(blurRadius: 16),
];


class GalleryAppBar extends StatelessWidget
    implements PreferredSizeWidget {

  final String tag;
  final bool search;
  final void Function()? onTap;

  const GalleryAppBar({
    super.key,
    required this.tag,
    this.search = false,
    this.onTap,
  });

  SelectionController get selection => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: const FlexibleSpace(),
      title: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: .start,
          children: [
            TagCount(tag: tag),
            ?search ? QueryInfo(tag: tag) : null,
          ],
        ),
      ),
      actions: [
        Obx(() => search && selection.off
                ? SortPopUp(tag: tag)
                : const SizedBox.shrink()
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}


class FlexibleSpace extends StatelessWidget {
  const FlexibleSpace({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Get.theme.scaffoldBackgroundColor.withAlpha(128),
            Colors.transparent,
          ],
          begin: .topCenter,
          end: .bottomCenter,
        ),
      ),
    );
  }
}


class TagCount extends StatelessWidget {
  final String tag;

  const TagCount({super.key, required this.tag});

  FileStore get files => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) => Obx(() {
    return '${files.length} files'.n
      ..color = Colors.white
      ..bodyLarge
      ..shadows = shadows;
  });
}


class QueryInfo extends StatelessWidget {
  final String tag;

  const QueryInfo({super.key, required this.tag});

  QueryController get query => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) => Obx(() {
    return switch (query.values.isEmpty) {
      true => const SizedBox.shrink(),
      false =>
        '$query'.n
          ..color = Colors.white
          ..bodySmall
          ..shadows = shadows,
    };
  });
}


class Actions extends StatelessWidget {
  final String tag;

  const Actions({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
