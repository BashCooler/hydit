import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:media_kit/media_kit.dart';

import 'utils/theme.dart';
import 'core/data/api.dart';
import 'core/data/repo.dart';
import 'features/gallery/page/gallery.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  await enableEdgeToEdge();

  Get.put(Repo(Client()));

  timeDilation = 1.0;
  runApp(const App());
}


Future<void> enableEdgeToEdge() async {
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ),
  );
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