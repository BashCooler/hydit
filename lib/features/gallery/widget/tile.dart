import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/reactive/file.dart';
import 'package:hydit/widgets/images.dart';

import '../getx/gallery.dart';
import '../getx/selection.dart';
import 'badges.dart';


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

  static const message =
      'It is required for HydrusFile to be loaded '
      'before building a Tile widget';

  @override
  Widget build(BuildContext context) {
    assert(file.loaded, message);

    final GalleryController gallery = Get.find(tag: tag);
    final SelectionController selection = Get.find(tag: tag);

    return GestureDetector(
      key: ValueKey(file.id),
      onTap: () => onTap?.call(file.id, index),
      onLongPress: () => onLongPress?.call(file.id),
      child: Stack(
        alignment: .bottomRight,
        children: [
          LinearHero(tag: file.id, child: Thumbnail(file)),
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