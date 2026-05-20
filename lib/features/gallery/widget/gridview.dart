import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:niku/extra/primitive.dart';
import 'package:expressive_refresh/expressive_refresh.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydrus_flutter/core/data/repo.dart';
import 'package:hydrus_flutter/core/ui/common.dart';
import 'package:hydrus_flutter/core/ui/images.dart';
import 'package:hydrus_flutter/core/domain/entities.dart';
import 'package:hydrus_flutter/core/domain/file_repo.dart';
import 'package:hydrus_flutter/features/search/getx/query.dart';

import '../getx/gallery.dart';
import '../getx/selection.dart';


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
    final Repo repo = Get.find();
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
          return GridView.builder(
            padding: .only(
              top: Get.mediaQuery.viewPadding.top + kToolbarHeight,
              right: 5,
              left: 5,
              bottom: Get.mediaQuery.viewPadding.bottom,
            ),
            physics: physics,
            controller: gallery.scroll,
            itemCount: files.length,
            gridDelegate: delegate,
            itemBuilder: (context, index) {
              final file = files[index];

              final tile = Tile(
                tag: tag,
                index: index,
                file: files[index],
                onTap: onTap,
                onLongPress: onLongPress,
              );

              if (file.width != -1) return tile;

              return FutureBuilder(
                future: repo.setMetadataFor(file),
                builder: (_, snapshot) {
                  if (snapshot.connectionState == .done) {
                    return tile;
                  } else {
                    return const ColoredBox(color: Colors.white10);
                  }
                },
              );
            },
          );
        }),
      ),
    );
  }
}


class Tile extends StatelessWidget {
  final String tag;
  final HydrusFile file;
  final int index;
  final void Function(int id, int index)? onTap;
  final void Function(int id)? onLongPress;

  const Tile({
    super.key,
    required this.tag,
    required this.index,
    required this.file,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final GalleryController gallery = Get.find(tag: tag);
    final SelectionController selection = Get.find(tag: tag);

    return GestureDetector(
      key: ValueKey(file.id),
      onTap: () => onTap?.call(file.id, index),
      onLongPress: () => onLongPress?.call(file.id),
      child: Stack(
        alignment: .bottomRight,
        children: [
          LinearHero(
            tag: file.id,
            child: Thumbnail(file),
          ),
          Obx(() {
            return AnimatedOpacity(
              opacity: gallery.badgesVisible ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInQuint,
              child: TileBadges(file),
            );
          }),
          Obx(() {
            final selected = selection.isSelected(file.id);
            return Container(
              decoration: BoxDecoration(
                border: .all(
                  color: selected
                      ? Colors.pink
                      : Colors.transparent,
                  width: 3,
                ),
                color: selected
                    ? Colors.black.withAlpha(32)
                    : Colors.transparent,
              ),
            );
          }),
        ],
      ),
    );
  }
}


class TileBadges extends StatelessWidget {
  final HydrusFile image;

  const TileBadges(this.image, {super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> badges = [];
    addTime(badges);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(mainAxisAlignment: .end, children: badges),
    );
  }

  void addTime(List<Widget> badges) {
    if (image.duration <= 0) return;
    final duration = Duration(milliseconds: image.duration);
    final time = stripHoursIfZero('$duration');
    badges.add(Badge(label: time.n));
  }

  String stripHoursIfZero(String duration) {
    final t = duration.split('.')[0].split(':');
    if (t[0] == '0') t.removeAt(0);
    return t.join(':');
  }
}
