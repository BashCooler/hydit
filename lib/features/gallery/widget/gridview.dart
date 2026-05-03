import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydrus_flutter/features/gallery/getx/selection.dart';
import 'package:hydrus_flutter/features/viewer/getx/page.dart';
import 'package:scroll_to_hide/scroll_to_hide.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydrus_flutter/core/data/repo.dart';
import 'package:hydrus_flutter/core/ui/common.dart';
import 'package:hydrus_flutter/core/ui/images.dart';
import 'package:hydrus_flutter/core/domain/entities.dart';
import 'package:hydrus_flutter/core/domain/di/images.dart';
import 'package:hydrus_flutter/features/search/getx/query.dart';
import 'package:hydrus_flutter/features/viewer/page/viewer.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';


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


class ViewerBindings implements Bindings {
  final int index;

  const ViewerBindings(this.index);

  @override
  void dependencies() {
    Get.put(PageGetxController(initial: index));
    Get.put(SnappingSheetController());
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

    return GestureDetector(
      key: ValueKey(image.id),
      onTap: () {
        switch (selection.selectionMode) {
          case true:
            selection.toggle(image.id);
            log(selection.selectedIds.toString());
          case false:
            Get.find<ScrollToHideController>().hide();
            query.badgeVisible.value = false;
            Get.to(() => Viewer(index),
              transition: .fadeIn,
              curve: Curves.easeInCubic,
              opaque: false,
              binding: ViewerBindings(index),
            );
        }
      },
      onLongPress: () {
        selection.toggle(image.id);
        log(selection.selectedIds.toString());
      },
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
    if (image.duration > 0) {
      final duration = Duration(milliseconds: image.duration).toString();
      final t = duration.split('.')[0].split(':');
      if (t[0] == '0') t.removeAt(0);
      final badge = Badge(
        label: Text(t.join(':')),
      );
      badges.add(badge);
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(mainAxisAlignment: .end, children: badges),
    );
  }
}