import 'package:get/get.dart';
import 'package:flutter/material.dart' hide RefreshCallback;
import 'package:expressive_refresh/expressive_refresh.dart';
import 'package:hydit/features/gallery/widget/widgets.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydit/services/repo.dart';
import 'package:hydit/widgets/images.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/gallery/getx/gallery.dart';


class GalleryGridView extends StatelessWidget {
  final String tag;
  final RefreshCallback? onRefresh;
  final void Function(int id, int index)? onTap;
  final void Function(int id, int index)? onLongPress;
  final bool Function(ScrollNotification) allowRefresh;
  final bool Function(int id)? selected;

  const GalleryGridView({
    super.key,
    required this.tag,
    this.onRefresh,
    this.onTap,
    this.onLongPress,
    this.allowRefresh = defaultScrollNotificationPredicate,
    this.selected,
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
        notificationPredicate: allowRefresh,
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
                files.next(index);

                final id = files.ids[index];

                return Stack(
                  children: [
                    LinearHero(
                      tag: id,
                      child: Thumbnail(repo.buildUrl(id, thumbnail: true)),
                    ),
                    Obx(() {
                      final file = files.elementAtOrNull(index);

                      if (file == null) {
                        return const SizedBox.shrink();
                      }

                      return Tile(
                        index: index,
                        id: id,
                        badges: TileBadges(file),
                        selected: selected?.call(file.id) ?? false,
                        showBadges: gallery.badges,
                        deleted: file.deleted,
                        onTap: onTap,
                        onLongPress: onLongPress,
                      );
                    }),
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
