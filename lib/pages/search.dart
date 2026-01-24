import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hydrus_flutter/theme.dart';
import 'package:hydrus_flutter/pages/settings.dart';
import 'package:hydrus_flutter/widgets/images.dart';

import '../api/hydrus.dart';
import '../api/hydrus_ui.dart';
import '../widgets/gridview.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  List<HydrusImage> images = [];
  late Client client;
  late var _clientFuture = createClientWithSettings().then((v) => client = v);

  void updateClient() {
    _clientFuture = createClientWithSettings().then((v) => client = v);
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

    final images = ids.map((id) => HydrusImage(id)).toList();

    setState(() => this.images = images);
  }

  // MARK: BUILD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Hydrus Client'),
        actions: [
          IconButton(
            onPressed: () => _openSettings(context),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: FutureBuilder(future: _clientFuture, builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Stack(
            children: [
              ImageGridViewBuilder(images, client),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: RepaintBoundary(
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(Consts.radius),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: Consts.blur, sigmaY: Consts.blur),
                      child: TextField(
                        decoration: InputDecoration(
                          filled: true,
                          hintText: 'Search',
                          fillColor: Consts.blackAlpha,
                        ),
                        onSubmitted: (String t) => searchForFiles([t]),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return Center(child: CircularProgressIndicator());
      }),
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
      snackBarAnimationStyle: AnimationStyle(
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