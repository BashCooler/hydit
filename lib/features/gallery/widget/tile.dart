import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file.dart';

import '../getx/gallery.dart';
import '../getx/selection.dart';

import 'badges.dart';


class Tile extends StatelessWidget {
  final String tag;
  final int index;
  final HydrusFile file;
  final void Function(int id, int index)? onTap;
  final void Function(int id, int index)? onLongPress;

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
    return GestureDetector(
      onTap: () {
        onTap?.call(file.id, index);
      },
      onLongPress: () {
        onLongPress?.call(file.id, index);
      },
      child: Stack(
        alignment: .bottomRight,
        children: [
          TileImage(tag: tag, file: file),
          Selection(tag: tag, id: file.id),
        ],
      ),
    );
  }
}


class TileImage extends StatelessWidget {
  final String tag;
  final HydrusFile file;

  const TileImage({
    super.key,
    required this.tag,
    required this.file,
  });

  GalleryController get gallery => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return Obx(() {

      if (file.removed) {
        return const SizedBox.shrink();
      }

      return AnimatedOpacity(
        opacity: gallery.badges ? 1 : 0,
        duration: 150.ms,
        curve: Curves.easeInQuint,
        child: TileBadges(file),
      );
    });
  }
}


class Selection extends StatelessWidget {
  final String tag;
  final int id;

  const Selection({
    super.key,
    required this.tag,
    required this.id,
  });

  SelectionController get selection => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return Obx(() {

      final selected = selection.isSelected(id);

      final border = selected
          ? Colors.pink
          : Colors.transparent;

      final color = selected
          ? Colors.black.withAlpha(32)
          : Colors.transparent;

      final decoration = BoxDecoration(
        border: .all(color: border, width: 3),
        color: color,
      );

      return Container(decoration: decoration);
    });
  }
}
