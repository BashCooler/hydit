import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/utils/theme.dart';
import 'package:hydit/features/search/page/search.dart';
import 'package:hydit/features/settings/page/settings.dart';
import 'package:full_swipe_back_gesture/full_swipe_back_gesture.dart';

import '../getx/gallery.dart';


class SearchFAB extends StatelessWidget {
  const SearchFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color.fromARGB(108, 0, 0, 0),
      shape: RoundedRectangleBorder(
        borderRadius: .circular(16),
      ),
      onPressed: () {

      },
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: .circular(16),
          child: BackdropFilter(
            filter: AppTheme.backdropFilter,
            child: Center(
              child: const Icon(Icons.search),
            ),
          ),
        ),
      ),
    );
  }
}


class HidableBottomBar extends StatelessWidget {
  final String tag;
  final Widget child;
  final bool show;

  const HidableBottomBar({
    super.key,
    required this.tag,
    required this.child,
    required this.show,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      curve: Curves.easeOutCubic,
      duration: const Duration(milliseconds: 350),
      offset: show ? .zero : const Offset(0, 1),
      child: Wrap(
        children: [
          child,
        ],
      ),
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
