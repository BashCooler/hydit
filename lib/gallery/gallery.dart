import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:hydrus_flutter/settings/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hydrus_flutter/api/hydrus.dart';
import 'package:hydrus_flutter/gallery/services.dart';
import 'package:hydrus_flutter/settings/settings.dart';
import 'package:hydrus_flutter/gallery/widgets/common.dart';
import 'package:hydrus_flutter/gallery/widgets/gridview.dart';


class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> with SingleTickerProviderStateMixin {
  final client = Get.find<Client>();
  final imgCtrl = Get.put<Images>(Images());

  @override
  void initState() {
    super.initState();
    updateClient();
    Get.put<SearchVisibility>(SearchVisibility());
    Get.put<QueryController>(QueryController());
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Hydrus client'),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => SettingsPage(callback: updateClient)),
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: Stack(
        alignment: .bottomRight,
        children: [
          const ImageGridViewBuilder(),
          SafeArea(
            child: Padding(
              padding: .all(AppTheme.searchPadding),
              child: Row(
                mainAxisAlignment: .end,
                children: [
                  FrostedGlass(
                    shape: .oval,
                    child: FilledIconButton(
                      onPressed: () => _showModalSheet(context),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}


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


void _showModalSheet(BuildContext context) {
  Navigator.push(
    context,
    ModalSheetRoute(
      swipeDismissible: true,
      builder: (context) => SearchPage(),
      viewportBuilder: (context, child) {
        return SheetViewport(
          padding: .only(top: MediaQuery.viewPaddingOf(context).top),
          child: child,
        );
      },
    ),
  );
}


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return const PopScope(
      child: SheetKeyboardDismissible(
        dismissBehavior: .onDragDown(isContentScrollAware: true),
        child: Sheet(
          scrollConfiguration: SheetScrollConfiguration(),
          child: Padding(
            padding: .symmetric(horizontal: 10.0),
            child: SafeArea(
              child: Column(
                spacing: 10.0,
                mainAxisAlignment: .end,
                children: [
                  Suggests(),
                  TagPanel(trailing: _TagPanelActions()),
                  TagSearchBar(),
                ],
              ),
            ),
          ),
        ),
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
      spacing: 4.0,
      children: [
        IconButton(
          tooltip: 'Clear tags',
          onPressed: () => queryController.clearTags(),
          icon: const Icon(Icons.clear),
        ),
        IconButton(
          tooltip: 'Search',
          onPressed: () {
            queryController.visible.value = false;
            queryController.textController.text = '';
            queryController.searchForFiles();
            Get.back();
          },
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }
}