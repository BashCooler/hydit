import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/theme.dart';
import 'core/data/api.dart';
import 'core/data/repository.dart';
import 'features/gallery/page/gallery.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  Get.put(prefs);
  Get.put(Repo(Client()));

  MediaKit.ensureInitialized();

  timeDilation = 1.0;
  runApp(const App());
}


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,
      theme: darkTheme(),
      home: Gallery(),
    );
  }
}