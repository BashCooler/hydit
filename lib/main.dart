import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'api/hydrus.dart';
import 'api/hydrus_ui.dart';
import 'package:hydrus_flutter/pages/settings.dart';
import 'package:hydrus_flutter/widgets/gridview.dart';


void main() {
  timeDilation = 1.0;
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.blue, brightness: .dark),
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<int> ids = [];
  late Client client;
  late var _clientFuture = createClientWithSettings().then((v) => client = v);

  void updateClient() {
    _clientFuture = createClientWithSettings().then((v) => client = v);
  }

  void searchForFiles(List<String> tags) async {

    // TODO implement multiple tags and tag handling
    // it throws HydrusBadRequestException if TextField is empty
    // need to add support for multiple tags and make so each tag
    // handled separately

    // TODO handle tags with '_' and with no '_'
    // change words in 2 word 1 space requests
    // add settings to turn that on/off

    // TODO return if client is invalid

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