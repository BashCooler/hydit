import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:expressive_refresh/expressive_refresh.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydit/core/domain/file_repo.dart';
import 'package:hydit/features/search/getx/query.dart';

import '../getx/gallery.dart';
import 'tile.dart';


class GalleryGridView extends StatelessWidget {
  final String tag;
  final void Function(int id, int index)? onTap;
  final void Function(int id)? onLongPress;
  final bool Function(ScrollNotification) allowRefresh;

  const GalleryGridView({
    super.key,
    required this.tag,
    this.onTap,
    this.onLongPress,
    this.allowRefresh = defaultScrollNotificationPredicate,
  });

  static const physics = BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
  );

  static const delegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 200,
    mainAxisSpacing: 5,
    crossAxisSpacing: 5,
  );

  @override
  Widget build(BuildContext context) {
    final QueryController query = Get.find();

    final FileRepo files = Get.find(tag: tag);
    final GalleryController gallery = Get.find(tag: tag);

    return GridViewObserver(
      controller: gallery.grid,
      child: ExpressiveRefreshIndicator(
        displacement: 100.0,
        notificationPredicate: allowRefresh,
        onRefresh: () => query.searchForFiles(),
        onStatusChange: (status) {
          switch (status) {
            case .done:
            case .canceled:
              gallery.refreshing.value = false;
              gallery.showActions();
            case _:
              gallery.refreshing.value = true;
          }
        },
        child: Obx(() {
          return Scrollbar(
            controller: gallery.scroll,
            child: GridView.builder(
              padding: .fromLTRB(
                8,
                Get.mediaQuery.viewPadding.top + kToolbarHeight,
                8,
                Get.mediaQuery.viewPadding.bottom,
              ),
              physics: physics,
              controller: gallery.scroll,
              itemCount: files.length,
              gridDelegate: delegate,
              itemBuilder: (context, index) {
                final file = files[index];
                return Obx(() {
                  switch (file.loaded) {
                    case false:
                      file.forceLoadMetadata();
                      return const ColoredBox(color: Colors.white10);
                    case true:
                      return Tile(
                        tag: tag,
                        index: index,
                        file: files[index],
                        onTap: onTap,
                        onLongPress: onLongPress,
                      );
                  }
                });
              },
            ),
          );
        }),
      ),
    );
  }
}
