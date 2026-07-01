import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/widgets/gradient.dart';
import 'package:niku/extra/primitive.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';

import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/search/getx/query.dart';
import 'package:hydit/features/search/widget/sorting.dart';

import '../getx/selection.dart';


const shadows = [
  Shadow(blurRadius: 16),
];


class GalleryAppBar extends StatelessWidget
    implements PreferredSizeWidget {

  final String tag;
  final bool search;
  final void Function()? onTap;
  final GlobalKey<InnerDrawerState>? state;

  const GalleryAppBar({
    super.key,
    required this.tag,
    this.search = false,
    this.state,
    this.onTap,
  });

  SelectionController get selection => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return GradientAppBar(
      automaticallyImplyLeading: false,
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
        Obx(() => selection.off && search
            ? SortPopUp(tag: tag)
            : const SizedBox.shrink(),
        ),
        if (state != null) OnGradientIconButton(
          Symbols.dock_to_left,
          tooltip: 'Sidebar',
          onPressed: () => state
              ?.currentState
              ?.toggle(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}


class TagCount extends StatelessWidget {
  final String tag;

  const TagCount({super.key, required this.tag});

  FileStore get files => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) => Obx(() {
    return '${files.ids.length} files'.n
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
