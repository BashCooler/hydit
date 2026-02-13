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
    return RepaintBoundary(
      child: switch (shape) {
            .rRect => ClipRRect(
          clipBehavior: .hardEdge,
          borderRadius: borderRadius ?? AppTheme.borderRadius,
          child: filter,
        ),
            .oval => ClipOval(
          clipBehavior: .hardEdge,
          child: filter,
        ),
        _ => ClipRect(
          clipBehavior: .hardEdge,
          child: filter,
        ),
      },
    );
  }
}


class FilledIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Icon icon;
  final EdgeInsets? padding;

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
      child: FrostedGlass(
        shape: .oval,
        child: Material(
          color: AppColors.blackWithAlpha,
          child: IconButton(
            padding: .all(AppTheme.buttonSize * 0.25),
            onPressed: onPressed,
            icon: icon,
          ),
        ),
      ),
    );
  }
}