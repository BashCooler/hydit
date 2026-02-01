import 'package:flutter_portal/flutter_portal.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:media_kit/media_kit.dart';

import 'package:hydrus_flutter/api/hydrus.dart';
import 'package:hydrus_flutter/search/search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hydrus_flutter/settings/theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  Get.put<SharedPreferences>(prefs);
  Get.put<Client>(Client());

  MediaKit.ensureInitialized();

  timeDilation = 1.0;
  runApp(const App());
}


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: GetMaterialApp(
        title: 'Flutter App',
        debugShowCheckedModeBanner: false,
        theme: darkTheme(),
        home: TabView(),
      ),
    );
  }
}


class TabView extends StatelessWidget {
  const TabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Main')),
      body: Column(
        children: [
          TextButton(
            onPressed: () => Get.to(SearchPage()),
            child: Text('To search 1'),
          ),
          TextButton(
            onPressed: () => Get.to(SearchPage()),
            child: Text('To search 2'),
          ),
        ],
      ),
    );
  }
}

