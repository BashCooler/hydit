import 'package:flutter/material.dart';
import 'package:hydrus_flutter/utils/theme.dart';


enum Shape {
  rect,
  rRect,
  oval,
}


class FrostedGlass extends StatelessWidget {
  final Widget child;
  final Shape? shape;
  final BorderRadius? borderRadius;

  const FrostedGlass({
    super.key,
    required this.child,
    this.shape = .rect,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final filter = BackdropFilter(
      filter: AppTheme.backdropFilter,
      child: child,
    );
    final clipRRect = ClipRRect(
      clipBehavior: .hardEdge,
      borderRadius: borderRadius ?? AppTheme.borderRadius,
      child: filter,
    );
    final clipOval = ClipOval(
      clipBehavior: .hardEdge,
      child: filter,
    );
    final clipRect = ClipRect(
      clipBehavior: .hardEdge,
      child: filter,
    );
    return RepaintBoundary(
      child: switch (shape) {
        Shape.rRect => clipRRect,
        Shape.oval => clipOval,
        _ => clipRect,
      },
    );
  }
}


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


class FilledTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const FilledTextButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      elevation: 2,
      shape: .circle,
      color: Colors.transparent,
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: .circular(50),
          clipBehavior: .hardEdge,
          child: BackdropFilter(
            filter: AppTheme.backdropFilter,
            child: Material(
              color: AppColors.blackWithAlpha,
              child: SizedBox(
                height: AppTheme.buttonSize,
                child: TextButton(
                  onPressed: onPressed,
                  child: Text(text),
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


class LinearHero extends StatelessWidget {
  final Object tag;
  final Widget child;

  const LinearHero({super.key, required this.tag, required this.child});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      createRectTween: (b, e) => RectTween(begin: b, end: e),
      child: child,
    );
  }
}