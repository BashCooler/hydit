import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;


class AcrylicFAB extends StatelessWidget {
  final void Function()? onTap;

  const AcrylicFAB({super.key, this.onTap});

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
            child: Center(
              child: const Icon(Icons.search),
            ),
          ),
        ),
      ),
    );
  }
}


class AcrylicPill extends StatelessWidget {
  final List<Widget> children;

  const AcrylicPill({super.key, required this.children});

  BorderRadius get radius => BorderRadius.circular(20);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(horizontal: 5),
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(
              padding: .symmetric(horizontal: 5),
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
                  style: IconButton.styleFrom(
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


class AcrylicText extends StatelessWidget {
  final int count;
  final EdgeInsets padding;

  const AcrylicText({
    super.key,
    required this.count,
    this.padding = const .fromLTRB(10, 8, 10, 8),
  });

  @override
  Widget build(BuildContext context) {
    return '$count'.n
      ..titleMedium
      ..color = Theme.of(context)
          .colorScheme
          .onPrimaryContainer
      ..n.padding = padding;
  }
}
