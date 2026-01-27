import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:hydrus_flutter/search/search.dart';
import 'package:hydrus_flutter/settings/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/hydrus.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // GetIt.instance.debugEventsEnabled = true;
  getIt.registerSingleton(GetPreferences(prefs));
  getIt.registerSingleton(GetClient());

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
      theme: darkTheme(),
      home: SearchPage(),
    );
  }
}

// MARK: SERVICES

final getIt = GetIt.instance;  // global

class GetClient {
  final Client client = Client();
  GetClient();
}

class GetPreferences {
  final SharedPreferences prefs;
  GetPreferences(this.prefs);
}
