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
import 'package:hydrus_flutter/features/viewer/getx/bindings.dart';

import '../getx/gallery.dart';
import '../getx/selection.dart';


class GalleryGridView extends StatelessWidget {
  final String tag;

  const GalleryGridView({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final QueryController query = Get.find();
    final SelectionController selection = Get.find(tag: tag);
    final GalleryController gallery = Get.find(tag: tag);

    final FileRepo fileRepo = Get.find(tag: tag);

    const physics = BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics());

    const delegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5.0,
    );

    return GridViewObserver(
      controller: gallery.grid,
      child: ExpressiveRefreshIndicator(
        displacement: 100.0,
        notificationPredicate: (_) => !selection.on,
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
        child: Obx(() => GridView.builder(
          padding: .only(
            top: Get.mediaQuery.viewPadding.top,
            right: 5,
            left: 5,
            bottom: 5,
          ),
          physics: physics,
          controller: gallery.grid.controller,
          itemCount: fileRepo.length,
          gridDelegate: delegate,
          itemBuilder: (_, index) => _TileBuilder(tag, index, fileRepo),
        )),
      ),
    );
  }
}

class _TileBuilder extends StatelessWidget {
  final String tag;
  final FileRepo files;
  final int index;

  const _TileBuilder(this.tag, this.index, this.files);

  @override
  Widget build(BuildContext context) {
    final file = files[index];

    if (file.width != -1) {
      return Tile(tag, index, files);
    }

    return FutureBuilder(
      future: Get.find<Repo>().setMetadataFor(file),
      builder: (_, snapshot) {
        if (snapshot.connectionState == .done) {
          return Tile(tag, index, files);
        } else {
          return const ColoredBox(color: Colors.white10);
        }
      },
    );
  }
}


class Tile extends StatelessWidget {
  final String tag;
  final FileRepo files;
  final int index;

  const Tile(this.tag, this.index, this.files, {super.key});

  @override
  Widget build(BuildContext context) {
    final file = files[index];

    final SelectionController selection = Get.find(tag: tag);
    final GalleryController gallery = Get.find(tag: tag);

    return GestureDetector(
      key: ValueKey(file.id),
      onTap: () {
        if (gallery.refreshing.value) return;
        switch (selection.on) {
          case true:
            selection.toggle(file.id);
            if (!selection.on) {
              gallery..unlockActions()..showActions();
            }
          case false:
            toViewer(index, files, gallery);
        }
      },
      onLongPress: () {
        if (gallery.refreshing.value) return;
        selection.toggle(file.id);
        if (selection.on) {
          gallery..hideActions()..lockActions();
        }
      },
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
