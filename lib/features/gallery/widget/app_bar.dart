import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/widgets/systems/gradient.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/search/getx/query.dart';

import '../getx/selection.dart';


class GalleryAppBar extends StatelessWidget
    implements PreferredSizeWidget {

  final String tag;
  final void Function()? onTap;
  final Widget? info;
  final Widget? trailing;
  final Widget? menuButton;

  const GalleryAppBar({
    super.key,
    required this.tag,
    this.onTap,
    this.info,
    this.trailing,
    this.menuButton,
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
            ?info,
          ],
        ),
      ),
      actions: [
        Obx(() {
          if (selection.off) {
            if (menuButton case Widget() && final menu) {
              return menu;
            }
          }
          return const SizedBox.shrink();
        }),
        ?trailing,
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


class const QueryInfo({
  super.key,
  required final QueryController query,
}) extends StatelessWidget {
  //
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      //
      if (query.isEmpty) {
        return const SizedBox.shrink();
      }

      return '$query'.n
        ..color = Colors.white
        ..bodySmall
        ..shadows = onGradientShadow;
    });
  }
}
