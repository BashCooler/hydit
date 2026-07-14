import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/widgets/gradient.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/search/getx/query.dart';
import 'package:hydit/features/search/widget/sorting.dart';

import '../getx/selection.dart';


class GalleryAppBar extends StatelessWidget
    implements PreferredSizeWidget {

  final String tag;
  final void Function()? onTap;
  final GlobalKey<InnerDrawerState>? state;

  const GalleryAppBar({
    super.key,
    required this.tag,
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
            QueryInfo(tag: tag),
          ],
        ),
      ),
      actions: [
        Obx(() => selection.off
            ? SortPopUp(tag: tag)
            : const SizedBox.shrink(),
        ),

        if (state != null)
          OnGradientIconButton(
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
      ..shadows = onGradientShadow;
  });
}


class QueryInfo extends StatelessWidget {
  final String tag;

  const QueryInfo({super.key, required this.tag});

  QueryController? get query => maybeFind(tag: tag);

  @override
  Widget build(BuildContext context) {
    final query = this.query;

    if (query == null || query.values.isEmpty) {
      return const SizedBox.shrink();
    }

    return '$query'.n
      ..color = Colors.white
      ..bodySmall
      ..shadows = onGradientShadow;
  }
}
