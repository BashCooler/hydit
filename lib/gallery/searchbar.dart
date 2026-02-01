import 'dart:developer';
import 'dart:ui';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydrus_flutter/gallery/gallery.dart';
import 'package:hydrus_flutter/settings/theme.dart';


class AnimatedLiquidSearchBar extends StatefulWidget {
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
  late final AnimationController _animationController;
  late final Animation<Offset> _slide;
  late final Worker _visibilityWorker;
  final _focusNode = FocusNode();
  final _queryController = Get.find<QueryController>();
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slide = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, 0.8),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    final visibility = Get.find<SearchVisibility>();
    _visibilityWorker = ever<bool>(visibility.visible, (v) {
      if (v) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _visibilityWorker.dispose();
    _focusNode.dispose();
    _queryController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: SafeArea(
        child: Padding(  // if you change this make sure to change Tween Offset
          padding: const EdgeInsets.all(Consts.searchPadding),
          child: RepaintBoundary(
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(Consts.radius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: Consts.blur, sigmaY: Consts.blur),
                child: Obx(() => PortalTarget(
                  visible: _queryController.visible.value,
                  anchor: const Aligned(follower: .bottomLeft, target: .topLeft),
                  portalFollower: Suggests(),
                  child: TextField(
                    focusNode: _focusNode,
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      fillColor: Consts.blackAlpha,
                    ),
                    onSubmitted: widget.onSearch,
                    onTapOutside: (_) {
                      _queryController.visible.value = false;
                      setState(() => _focusNode.unfocus());
                    },
                    onChanged: (q) => _queryController.onChange(q),
                    onTap: () {
                      final q = _textController.text;
                      _queryController.onChange(q);
                    },
                  ),
                )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class Suggests extends StatelessWidget {
  const Suggests({super.key});

  @override
  Widget build(BuildContext context) {
    final queryController = Get.find<QueryController>();
    return Padding(
      padding: EdgeInsetsGeometry.only(
        right: Consts.searchPadding * 2,
        bottom: Consts.searchPadding,
      ),
      child: RepaintBoundary(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: Consts.listTileHeight * 7),
          child: ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: BorderRadiusGeometry.circular(Consts.radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: Consts.blur,
                sigmaY: Consts.blur,
              ),
              child: Card.outlined(
                color: Consts.blackAlpha,
                margin: EdgeInsets.zero,
                child: Obx(() => ListView.builder(
                  shrinkWrap: true,
                  reverse: true,
                  itemCount: queryController.suggests.length,
                  itemBuilder: (context, index) {
                    final tag = queryController.suggests[index];
                    return ListTile(
                      minTileHeight: Consts.listTileHeight,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: Consts.searchPadding,
                      ),
                      title: Text(tag.value),
                      trailing: Text(tag.count.toString()),
                      onTap: () => log(tag.value),
                    );
                  },
                )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
