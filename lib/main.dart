import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:media_kit/media_kit.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:flutter_portal/flutter_portal.dart';

import 'utils/theme.dart';
import 'services/repo.dart';
import 'reactive/files.dart';
import 'features/gallery/page/gallery.dart';
import 'features/gallery/getx/bindings.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');

  await enableEdgeToEdge();

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
    final tag = 'Gallery-${DateTime.now().microsecondsSinceEpoch}';
    return Portal(
      child: GetMaterialApp(
        title: 'Flutter App',
        debugShowCheckedModeBanner: false,
        theme: darkTheme(),
        initialRoute: '/',
        getPages: [
          GetPage(
            name: '/',
            transition: .rightToLeft,
            curve: Curves.easeInOutCubic,
            page: () => Gallery(tag: tag),
            binding: GalleryBindings(tag, FileStore()),
          ),
        ],
      ),
    );
  }
}