import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import 'package:hydrus_flutter/theme.dart';
import 'package:hydrus_flutter/pages/settings.dart';
import 'package:hydrus_flutter/widgets/images.dart';

import '../api/hydrus.dart';
import '../main.dart';
import '../widgets/gridview.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Client client = getIt<GetClient>().client;

  @override
  void initState() {
    super.initState();
    updateClient();
  }

  void updateClient() {
    final prefs = getIt<GetPreferences>().prefs;
    final key = prefs.getString('Hydrus API key') ?? '';
    final uri = Uri.parse(prefs.getString('URL') ?? '');
    getIt<GetClient>().client.updateClientFromPrefs(key: key, uri: uri);
  }

  void searchForFiles(List<String> tags) async {

    // TODO tag chips see: https://api.flutter.dev/flutter/material/Chip-class.html

    List<int> ids = [];
    try {
      ids = await client.getSearchFiles(tags);
    } on HydrusNoServiceException {
      showSnackBar('No connection with Hydrus');
    } on HydrusTimeoutException {
      showSnackBar('No response (timeout)');
    }

    getIt<GetImages>().update(ids.map((id) => HydrusImage(id)).toList());
  }

  // MARK: BUILD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Hydrus Client'),
        actions: [
          IconButton(
            onPressed: () => _openSettings(context),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Stack(
        alignment: .bottomCenter,
        children: [
          ImageGridViewBuilder(),
          AnimatedPadding(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: AnimatedLiquidSearchBar(onSearch: (s) => searchForFiles([s])),
          ),
        ],
      ),
    );
  }

  // MARK: SNACKBAR

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: RepaintBoundary(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: Consts.blur, sigmaY: Consts.blur),
            child: Text(message),
          ),
        ),
        backgroundColor: Consts.blackAlpha,
      ),
      snackBarAnimationStyle: const AnimationStyle(
        curve: Curves.easeInExpo,
        reverseCurve: Curves.easeOutExpo,
        duration: Duration(milliseconds: 1000),
        reverseDuration: Duration(milliseconds: 1000),
      ),
    );
  }

  // MARK: SETTINGS

  void _openSettings(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SettingsPage()),
    );
    updateClient();
  }
}

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
    final visibility = watchIt<SearchVisibilityController>().value;
    switch (visibility) {
      case SearchState.hidden:
        _controller.forward();
      case SearchState.visible:
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