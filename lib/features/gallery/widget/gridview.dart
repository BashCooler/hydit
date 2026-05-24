import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:niku/extra/primitive.dart';
import 'package:expressive_refresh/expressive_refresh.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydit/core/data/repo.dart';
import 'package:hydit/core/ui/common.dart';
import 'package:hydit/core/ui/images.dart';
import 'package:hydit/core/domain/entities.dart';
import 'package:hydit/core/domain/file_repo.dart';
import 'package:hydit/features/search/getx/query.dart';

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
              opacity: file.ready.value && gallery.badgesVisible ? 1 : 0,
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
  final HydrusFile file;

  const TileBadges(this.file, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        alignment: .end,
        spacing: 2,
        runSpacing: 2,
        children: BadgesBuilder(file)
            .duration()
            .addNumerical('volume', 'v')
            .addNumerical('chapter', 'c')
            .addNumerical('page', 'p')
            .build(),
      ),
    );
  }
}


class BadgesBuilder {
  final HydrusFile _file;

  final List<Widget> _badges = [];

  BadgesBuilder(this._file);

  BadgesBuilder duration() {
    if (_file.duration <= 0) return this;

    final duration = Duration(milliseconds: _file.duration);
    final time = _stripZeros('$duration');
    _badges.add(Badge(label: time.n));

    return this;
  }

  static String _stripZeros(String duration) {
    final t = duration.split('.').first.split(':');
    if (t.first == '0') {
      t.removeAt(0);
      if (t.first == '00') t.first = '0';
    }
    return t.join(':');
  }

  BadgesBuilder addNumerical(String namespace, [String? prefix]) {
    final value = _file
        .namespaces[namespace]?.first
        .replaceAll(RegExp(r'^0+'), '');
    if (value != null) _badges.add(Badge(label: '${prefix ?? ''}$value'.n));
    return this;
  }

  List<Widget> build() => _badges;
}
