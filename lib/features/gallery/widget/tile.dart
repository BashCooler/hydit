import 'package:flutter/material.dart';

import 'package:hydit/reactive/file.dart';
import 'package:hydit/widgets/images.dart';


class Tile extends StatelessWidget {
  final HydrusFile file;
  final int index;
  final Widget thumbnail;
  final Widget? badges;
  final void Function(int id, int index)? onTap;
  final void Function(int id, int index)? onLongPress;
  final bool selected;

  const Tile({
    super.key,
    required this.index,
    required this.file,
    this.onTap,
    this.onLongPress,
    this.selected = false,

    required this.thumbnail,
    required this.badges,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey(file.id),
      onTap: () => onTap
          ?.call(file.id, index),
      onLongPress: () => onLongPress
          ?.call(file.id, index),
      child: Stack(
        alignment: .bottomRight,
        children: [
          LinearHero(
            tag: file.id,
            child: thumbnail,
          ),
          AnimatedOpacity(
            opacity: badges != null ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInQuint,
            child: badges,
          ),
          Container(
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
          ),
        ],
      ),
    );
  }
}