import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:hydrus_flutter/search/search.dart';

import '../settings/theme.dart';


class AnimatedLiquidSearchBar extends StatefulWidget with WatchItStatefulWidgetMixin {
  final ValueChanged<String> onSearch;

  const AnimatedLiquidSearchBar({
    super.key,
    required this.onSearch,
  });

  @override
  State<AnimatedLiquidSearchBar> createState() => _AnimatedLiquidSearchBarState();
}

class _AnimatedLiquidSearchBarState extends State<AnimatedLiquidSearchBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slide = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, 0.8),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibility = watchIt<SearchVisibility>().value;
    switch (visibility) {
      case false:
        _controller.forward();
      case true:
        _controller.reverse();
    }
    return SlideTransition(
      position: _slide,
      child: LiquidSearchBar(onSearch: widget.onSearch),
    );
  }
}

class LiquidSearchBar extends StatelessWidget {
  final ValueChanged<String> onSearch;

  const LiquidSearchBar({
    super.key,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(  // if you change this make sure to change Tween Offset
        padding: const EdgeInsets.all(15.0),
        child: RepaintBoundary(
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(Consts.radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: Consts.blur, sigmaY: Consts.blur),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search',
                  fillColor: Consts.blackAlpha,
                ),
                onSubmitted: onSearch,
              ),
            ),
          ),
        ),
      ),
    );
  }
}