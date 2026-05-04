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
import 'package:hydrus_flutter/core/domain/di/images.dart';
import 'package:hydrus_flutter/features/search/getx/query.dart';
import 'package:hydrus_flutter/features/viewer/page/viewer.dart';
import 'package:hydrus_flutter/features/viewer/getx/bindings.dart';

import '../getx/gallery.dart';
import '../getx/selection.dart';


class ImageGridViewBuilder extends StatelessWidget {
  const ImageGridViewBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    final Images images = Get.find();
    final QueryController query = Get.find();
    final GridObserverController grid = Get.find();
    final SelectionController selection = Get.find();
    final GalleryController gallery = Get.find();

    const physics = BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics());

    const delegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5.0,
    );

    return GridViewObserver(
      controller: grid,
      child: ExpressiveRefreshIndicator(
        displacement: 100.0,
        notificationPredicate: (_) => !selection.selectionMode,
        onRefresh: () => query.searchForFiles(),
        onStatusChange: (status) {
          switch (status) {
            case .done:
            case .canceled:
              gallery.refreshing.value = false;
            case _:
              gallery.refreshing.value = true;
          }
        },
        child: Obx(() => GridView.builder(
          padding: .only(
            top: Get.mediaQuery.viewPadding.top,
            right: 5,
            left: 5,
            bottom: 5,
          ),
          physics: physics,
          controller: grid.controller,
          itemCount: images.length,
          gridDelegate: delegate,
          itemBuilder: (_, index) => _TileBuilder(index),
        )),
      ),
    );
  }
}

class _TileBuilder extends StatelessWidget {
  final int index;

  const _TileBuilder(this.index);

  @override
  Widget build(BuildContext context) {
    final image = Get.find<Images>().images[index];

    if (image.width != -1) {
      return _Tile(index, image);
    }

    return FutureBuilder(
      future: Get.find<Repo>().setMetadataFor(image),
      builder: (_, snapshot) {
        if (snapshot.connectionState == .done) {
          return _Tile(index, image);
        } else {
          return const ColoredBox(color: Colors.white10);
        }
      },
    );
  }
}


class _Tile extends StatelessWidget {
  final int index;
  final HydrusImage image;

  const _Tile(this.index, this.image);

  @override
  Widget build(BuildContext context) {
    final QueryController query = Get.find();
    final SelectionController selection = Get.find();
    final GalleryController gallery = Get.find();

    return GestureDetector(
      key: ValueKey(image.id),
      onTap: () {
        if (gallery.refreshing.value) return;
        switch (selection.selectionMode) {
          case true:
            selection.toggle(image.id);
          case false:
            final tag = 'viewer-${DateTime.now().microsecondsSinceEpoch}';
            Get.find<GalleryController>().hide();
            query.badgeVisible.value = false;
            Get.to(() => Viewer(index, tag: tag),
              transition: .fadeIn,
              curve: Curves.easeInCubic,
              opaque: false,
              binding: ViewerBindings(index: index, tag: tag),
            );
        }
      },
      onLongPress: () => selection.toggle(image.id),
      child: Stack(
        alignment: .bottomRight,
        children: [
          LinearHero(
            tag: image.id,
            child: Thumbnail(image),
          ),
          Obx(() {
            final visible = query.badgeVisible.value;
            return AnimatedOpacity(
              opacity: visible ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInQuint,
              child: _TileBadges(image),
            );
          }),
          Obx(() {
            final selected = selection.isSelected(image.id);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 75),
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


class _TileBadges extends StatelessWidget {
  final HydrusImage image;

  const _TileBadges(this.image);

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
