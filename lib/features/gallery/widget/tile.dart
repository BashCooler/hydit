import 'package:flutter/material.dart';

import 'package:hydit/utils/theme.dart';


class Tile extends StatelessWidget {
  final int index;
  final int id;
  final Widget? badges;
  final bool selected;
  final bool showBadges;
  final bool deleted;
  final void Function(int id, int index)? onTap;
  final void Function(int id, int index)? onLongPress;

  const Tile({
    super.key,
    required this.index,
    required this.id,
    this.badges,
    this.selected = false,
    this.showBadges = true,
    this.deleted = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      key: ValueKey(id),
      duration: deletionDuration,
      scale: deleted ? 0 : 1,
      child: GestureDetector(
        onTap: () => onTap?.call(id, index),
        onLongPress: () => onLongPress?.call(id, index),
        child: Stack(
          alignment: .bottomRight,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 120),
              switchInCurve: Curves.easeInQuint,
              switchOutCurve: Curves.easeInQuint,
              child: showBadges && badges != null
                  ? badges
                  : const SizedBox.shrink(),
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
      ),
    );
  }
}