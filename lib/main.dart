import 'package:flutter/material.dart';
import 'hydrus.dart';

void main() {
  // All the preparations go here
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

  Client client = Client('86106807bd3cfe58cd0c5664981799dbaf978454a91b26afd3c5a60e3ad2c813');

  void searchForFiles(List<String> tags) async {
    var searchResponse = await client.getSearchFiles(tags);
    setState(() {
      text = searchResponse;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Hydrus Client'),
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
}
