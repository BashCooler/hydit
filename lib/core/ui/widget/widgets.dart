import 'package:flutter/material.dart';
import 'package:hydrus_flutter/utils/theme.dart';


class FilledIconButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FilledIconButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Ink(
          decoration: const ShapeDecoration(
            color: AppTheme.blackAlpha,
            shape: CircleBorder(),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: const Icon(Icons.search),
          ),
        ),
      ),
    );
  }
}


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