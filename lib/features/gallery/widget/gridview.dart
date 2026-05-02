import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to_hide/scroll_to_hide.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydrus_flutter/core/data/repo.dart';
import 'package:hydrus_flutter/core/ui/common.dart';
import 'package:hydrus_flutter/core/ui/images.dart';
import 'package:hydrus_flutter/core/domain/entities.dart';
import 'package:hydrus_flutter/core/domain/di/images.dart';
import 'package:hydrus_flutter/features/search/getx/query.dart';
import 'package:hydrus_flutter/features/viewer/page/viewer.dart';


class ImageGridViewBuilder extends StatelessWidget {
  const ImageGridViewBuilder({super.key});

  @override
  Widget build(BuildContext context) {

    final Images images = Get.find();
    final QueryController query = Get.find();
    final GridObserverController grid = Get.find();

    const physics = BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics());

    const delegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5.0,
    );

    return Padding(
      padding: .symmetric(horizontal: 5.0),
      child: GridViewObserver(
        controller: grid,
        child: RefreshIndicator(
          displacement: 100.0,
          onRefresh: () async => query.searchForFiles(),
          child: Obx(() => GridView.builder(
            physics: physics,
            controller: grid.controller,
            itemCount: images.length,
            gridDelegate: delegate,
            itemBuilder: (_, index) => _TileBuilder(index),
          )),
        ),
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
    final query = Get.find<QueryController>();
    return GestureDetector(
      key: ValueKey(image.id),
      onTap: () {
        Get.find<ScrollToHideController>().hide();
        query.badgeVisible.value = false;
        Get.to(() => Viewer(index),
            transition: .fadeIn,
            curve: Curves.easeInCubic,
            opaque: false);
      },
      child: Stack(
        alignment: .bottomRight,
        children: [
          LinearHero(
            tag: image.id,
            child: Thumbnail(image),
          ),
          Obx(() => query.badgeVisible.value
              ? _TileBadges(image)
              : const SizedBox.shrink()),
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
    if (image.duration > 0) {
      final duration = Duration(milliseconds: image.duration).toString();
      final t = duration.split('.')[0].split(':');
      if (t[0] == '0') t.removeAt(0);
      badges.add(Text(t.join(':')));
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(mainAxisAlignment: .end, children: badges),
    );
  }
}