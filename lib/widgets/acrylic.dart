import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as m;
import 'package:niku/namespace.dart' as n;


class FAB extends StatelessWidget {
  final Widget? icon;
  final void Function()? onTap;

  const FAB({super.key, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color.fromARGB(108, 0, 0, 0),
      shape: RoundedRectangleBorder(
        borderRadius: .circular(16),
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .onInverseSurface
              .withAlpha(92),
        ),
      ),
      onPressed: onTap,
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: .circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }
}


class Pill extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final EdgeInsets margin;

  const Pill({
    super.key,
    required this.children,
    this.padding = const .symmetric(horizontal: 4),
    this.margin = const .symmetric(horizontal: 5),
  });

  const Pill.text({
    super.key,
    required this.children,
    this.margin = const .symmetric(horizontal: 5),
  })
      : padding = const .symmetric(horizontal: 5.4);

  BorderRadius get radius => BorderRadius.circular(20);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: const Color.fromARGB(108, 0, 0, 0),
                borderRadius: radius,
                border: Border.fromBorderSide(
                  BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .onInverseSurface
                        .withAlpha(92),
                  ),
                ),
              ),
              child: IconButtonTheme(
                data: IconButtonThemeData(
                  style: m.IconButton.styleFrom(
                    foregroundColor: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer,
                  ),
                ),
                child: Row(
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class Text extends StatelessWidget {
  final dynamic text;
  final EdgeInsets padding;

  const Text(this.text, {
    super.key,
    this.padding = const .fromLTRB(10, 8, 10, 8),
  });

  @override
  Widget build(BuildContext context) {
    return text.toString().n
      ..titleMedium
      ..color = Theme.of(context)
          .colorScheme
          .onPrimaryContainer
      ..n.padding = padding;
  }
}


class TextButton extends StatelessWidget {
  final void Function()? onPressed;
  final Widget child;

  const TextButton({super.key, this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return m.TextButton(
      style: m.TextButton.styleFrom(
        foregroundColor: Theme.of(context)
            .colorScheme
            .onPrimaryContainer,
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}


class IconButton extends StatelessWidget {
  final String? tooltip;
  final Icon icon;
  final void Function()? onPressed;

  const IconButton({
    super.key,
    required this.icon,
    this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Pill(
      padding: .zero,
      margin: .zero,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 40),
          child: m.IconButton(
            padding: .zero,
            tooltip: tooltip,
            icon: icon,
            onPressed: onPressed,
          ),
        ),
      ],
    );
  }
}


class More extends StatelessWidget {
  final List<PopupMenuItem<dynamic>> items;

  const More(this.items, {super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context)
            .colorScheme
            .onPrimaryContainer,
      ),
      itemBuilder: (context) => items,
    );
  }
}

