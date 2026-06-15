import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/extra/primitive.dart';

import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/search/getx/query.dart';

import '../getx/gallery.dart';


class GalleryAppBar extends StatelessWidget
    with GalleryInfo
    implements PreferredSizeWidget {

  final String tag;
  final List<Widget>? actions;

  const GalleryAppBar({super.key, required this.tag, this.actions});

  @override
  Widget build(BuildContext context) {
    final GalleryController gallery = Get.find(tag: tag);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: const FlexibleSpace(),
      title: GestureDetector(
        onTap: gallery.scrollUp,
        child: Obx(() {
          return Column(
            crossAxisAlignment: .start,
            children: [
              count(tag),
              ?query(Get.find<QueryController>()),
            ],
          );
        }),
      ),
      actions: actions,
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


mixin GalleryInfo {
  static const shadows = [ Shadow(blurRadius: 16) ];

  Widget count(String tag) {
    final FileStore files = Get.find(tag: tag);

    return '${files.length} files'.n
      ..color = Colors.white
      ..bodyLarge
      ..shadows = shadows;
  }

  Widget? query(QueryController query) {
    if (query.values.isEmpty) return null;

    final text = '${query.values}'
        .replaceAll(RegExp(r'[\[\]]'), '');

    return text.n
      ..color = Colors.white
      ..bodySmall
      ..shadows = shadows;
  }
}
