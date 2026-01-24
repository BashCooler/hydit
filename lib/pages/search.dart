import 'package:flutter/material.dart';
import 'package:hydrus_flutter/pages/settings.dart';

import '../api/hydrus.dart';
import '../api/hydrus_ui.dart';
import '../widgets/gridview.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<int> ids = [];
  late Client client;
  late var _clientFuture = createClientWithSettings().then((v) => client = v);

  void updateClient() {
    _clientFuture = createClientWithSettings().then((v) => client = v);
  }

  void searchForFiles(List<String> tags) async {

    List<int> ids = [];
    try {
      ids = await client.getSearchFiles(tags);
    } on HydrusNoServiceException {
      showSnackBar('No connection with Hydrus');
    } on HydrusTimeoutException {
      showSnackBar('No response (timeout)');
    }

    setState(() {
      this.ids = ids;
    });
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
      body: FutureBuilder(
          future: _clientFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  TextField(
                    decoration: InputDecoration(filled: true, hintText: 'Search'),
                    onSubmitted: (String t) => searchForFiles([t]),
                  ),
                  Expanded(child: ImageGridViewBuilder(ids, client)),
                ],
              );
            }
            return Center(child: CircularProgressIndicator());
          }
      ),
    );
  }

  // MARK: SNACKBAR

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(String message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.black)),
        duration: const Duration(milliseconds: 5000),
        behavior: .fixed,  // floating is better but animation is ass
        backgroundColor: Theme.of(context).colorScheme.outline,
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