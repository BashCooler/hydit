import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:hydrus_flutter/settings/theme.dart';
import 'package:hydrus_flutter/settings/settings.dart';
import 'package:hydrus_flutter/viewer/images.dart';
import 'package:hydrus_flutter/search/searchbar.dart';

import '../api/hydrus.dart';
import '../main.dart';
import 'gridview.dart';


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
