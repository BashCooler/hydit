import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:media_kit/media_kit.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:permission_handler/permission_handler.dart';

import 'features/gallery/bindings.dart';
import 'services/repo.dart';
import 'widgets/shell.dart';
import 'utils/theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('settings');

  await enableEdgeToEdge();
  await Permission.notification.request();

  Get.put(Repo());

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
    final page = GalleryPage()
        .withSearch()
        .withEditor();

    final gallery = AppShell(
      dialog: page.dialog,
      child: page.build(),
    );

    return GetMaterialApp(
      title: 'Hydit',
      debugShowCheckedModeBanner: false,
      theme: darkTheme(),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          transition: .rightToLeft,
          curve: Curves.easeInOutCubic,
          page: () => gallery,
          binding: GalleryBindings(page),
        ),
      ],
    );
  }
}