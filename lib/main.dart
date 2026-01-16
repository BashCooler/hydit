import 'package:flutter/material.dart';
import 'package:hydrus_flutter/settings.dart';
import 'hydrus_api/hydrus.dart';
import 'hydrus_api/hydrus_ui.dart';

void main() {
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
  String text = 'Text';

  void searchForFiles(List<String> tags) async {
    Client client = await createClientWithSettings();

    // TODO implement multiple tags and tag handling
    // now it throws HydrusBadRequestException if TextField is empty
    // need to add support for multiple tags and make so each tag
    // handled separately

    // TODO handle tags with '_' and with no '_'
    // on UI level or API level?

    List<int> ids = [];
    try {
      ids = await client.getSearchFiles(tags);
    } on HydrusNoServiceException {
      showSnackBar('No connection with Hydrus');
    } on HydrusTimeoutException {
      showSnackBar('No response (timeout)');
    }

    setState(() {
      text = ids.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Hydrus Client'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => SettingsPage()),
            ),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(filled: true, hintText: 'Search'),
            onSubmitted: (String t) => searchForFiles([t]),
          ),
          Expanded(
            child: Center(
              child: Text(text, style: TextStyle(fontSize: 20))
            ),
          )
        ],
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
}
