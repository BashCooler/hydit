import 'package:get/get.dart';
import 'package:flutter/material.dart' hide RefreshCallback;
import 'package:expressive_refresh/expressive_refresh.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydit/utils/theme.dart';
import 'package:hydit/services/repo.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/widgets/common/images.dart';

import 'widgets.dart';
import '../getx/gallery.dart';


class GalleryGridView extends StatelessWidget {
  final String tag;
  final RefreshCallback? onRefresh;
  final void Function(int id, int index)? onTap;
  final void Function(int id, int index)? onLongPress;
  final void Function(int index)? onBuild;
  final bool Function(ScrollNotification) allowRefresh;

  const GalleryGridView({
    super.key,
    required this.tag,
    this.onRefresh,
    this.onTap,
    this.onLongPress,
    this.onBuild,
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

  Repo get repo => Get.find();

  FileStore get files => Get.find(tag: tag);

  GalleryController get gallery => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return GridViewObserver(
      controller: gallery.grid,
      child: ExpressiveRefreshIndicator(
        displacement: 100.0,
        notificationPredicate: (notification) {
          return onRefresh != null && allowRefresh(notification);
        },
        onRefresh: onRefresh ?? () async {},
        onStatusChange: (status) {
          switch (status) {
            case .done:
            case .canceled:
              gallery.loading.value = false;
            case _:
              gallery.loading.value = true;
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
                onBuild?.call(index);

                final file = files[index];

                return Stack(
                  key: ValueKey(file.id),
                  children: [
                    Obx(
                      () => AnimatedScale(
                        duration: deletionDuration,
                        scale: file.removed ? 0 : 1,
                        child: LinearHero(
                          tag: file.id,
                          child: Thumbnail(file.thumbnailUrl),
                        ),
                      ),
                    ),
                    Tile(
                      tag: tag,
                      index: index,
                      file: file,
                      onTap: onTap,
                      onLongPress: onLongPress,
                    ),
                  ],
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
