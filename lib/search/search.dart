import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import 'package:hydrus_flutter/settings/theme.dart';
import 'package:hydrus_flutter/settings/settings.dart';
import 'package:hydrus_flutter/viewer/images.dart';
import 'package:hydrus_flutter/search/searchbar.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../api/hydrus.dart';
import '../main.dart';
import 'gridview.dart';


class SearchPage extends WatchingStatefulWidget {
  const SearchPage({super.key});

  final pageId = 0;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Client client = getIt<Client>();
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    updateClient();
    getIt.pushNewScope(
      scopeName: 'Page ${widget.pageId}',
      init: (getIt) {
        getIt.registerSingleton(SearchVisibilityController());
        getIt.registerSingleton(GetImages());
        getIt.registerSingleton(GridObserverController());
      },
    );
  }

  void updateClient() {
    final prefs = getIt<GetPreferences>().prefs;
    final key = prefs.getString('Hydrus API key') ?? '';
    final uri = Uri.parse(prefs.getString('URL') ?? '');
    getIt<Client>().updateClientFromPrefs(key: key, uri: uri);
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
            child: AnimatedLiquidSearchBar(
                onSearch: (s) => searchForFiles([s])
            ),
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


// MARK: SERVICES

class GetImages extends ValueNotifier<List<HydrusImage>> {
  GetImages() : super([]);
  void update(List<HydrusImage> images) => value = images;
}

enum SearchState {visible, hidden}

class SearchVisibilityController extends ValueNotifier<SearchState> {
  SearchVisibilityController() : super(SearchState.visible);

  void show() => value = SearchState.visible;
  void hide() => value = SearchState.hidden;
}
