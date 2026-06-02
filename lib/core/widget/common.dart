import 'package:flutter/material.dart';
import 'package:hydit/utils/theme.dart';


class FilledIconButton extends StatelessWidget {
  final Icon icon;
  final EdgeInsets? padding;
  final VoidCallback? onPressed;

  const FilledIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? .zero,
      child: PhysicalModel(
        elevation: 2,
        shape: .circle,
        color: Colors.transparent,
        child: RepaintBoundary(
          child: ClipOval(
            clipBehavior: .hardEdge,
            child: BackdropFilter(
              filter: AppTheme.backdropFilter,
              child: Material(
                color: AppColors.blackWithAlpha,
                child: IconButton(
                  padding: .all(AppTheme.buttonSize * 0.25),
                  onPressed: onPressed,
                  icon: icon,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


/// Makes [PageView] scroll more responsive. Still not perfect.
class SnappyPageScrollPhysics extends PageScrollPhysics {
  const SnappyPageScrollPhysics({super.parent});

  @override
  SnappyPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SnappyPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
    mass: 1,
    stiffness: 250,
    damping: 30,
  );
}
