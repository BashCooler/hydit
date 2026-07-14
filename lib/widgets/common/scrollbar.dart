import 'package:flutter/material.dart';


class ColoredScrollbar extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;

  const ColoredScrollbar({
    super.key,
    required this.child,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.error;

    return ScrollbarTheme(
      data: theme.scrollbarTheme.copyWith(
        thumbColor: WidgetStatePropertyAll(color),
      ),
      child: Scrollbar(controller: controller, child: child),
    );
  }
}
