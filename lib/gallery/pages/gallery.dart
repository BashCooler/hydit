import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydrus_flutter/gallery/widgets/common.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hydrus_flutter/api/hydrus.dart';
import 'package:hydrus_flutter/gallery/pages/search.dart';
import 'package:hydrus_flutter/gallery/widgets/gridview.dart';
import 'package:hydrus_flutter/gallery/services.dart';
import 'package:hydrus_flutter/settings/settings.dart';

import '../../settings/theme.dart';


class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> with SingleTickerProviderStateMixin {
  final client = Get.find<Client>();
  final imgCtrl = Get.put<Images>(Images());
  late final AnimationController _animationController;
  late final Animation<Offset> _slide;
  late final Worker _visibilityWorker;

  @override
  void initState() {
    super.initState();
    updateClient();
    Get.put<SearchVisibility>(SearchVisibility());
    Get.put<QueryController>(QueryController());

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
    super.dispose();
    _animationController.dispose();
    _visibilityWorker.dispose();
  }

  void updateClient() {
    final prefs = Get.find<SharedPreferences>();
    final key = prefs.getString('Hydrus API key') ?? '';
    final uri = Uri.parse(prefs.getString('URL') ?? '');
    client.updateClient(key: key, uri: uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Hydrus client'),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => SettingsPage(callback: updateClient)),
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: Stack(
        alignment: .bottomCenter,
        children: [
          const ImageGridViewBuilder(),
          SafeArea(
            child: SlideTransition(
              position: _slide,
              child: Padding(
                padding: const .all(AppTheme.searchPadding),
                child: LiquidGlass(
                  child: TagPanel(
                    onTap: () => Get.dialog(
                      const SearchPage(),
                      barrierColor: AppTheme.blackAlpha,
                      transitionDuration: const Duration(milliseconds: 200),
                      transitionCurve: Curves.easeInOutBack,
                      useSafeArea: false,
                    ),
                    trailing: const _TagPanelActions(),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}


class _TagPanelActions extends StatelessWidget {
  const _TagPanelActions();

  @override
  Widget build(BuildContext context) {
    final queryController = Get.find<QueryController>();
    return Row(
      spacing: 5.0,
      children: [
        IconButton(
          tooltip: 'Clear tags',
          onPressed: () => queryController.clearTags(),
          icon: const Icon(Icons.clear),
        ),
        IconButton(
          tooltip: 'Search',
          onPressed: () => queryController.searchForFiles(),
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }
}