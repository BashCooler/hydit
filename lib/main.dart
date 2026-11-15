import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:media_kit/media_kit.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/cache.dart';
import 'package:hydit/services/services.dart';

import 'package:hydit/features/gallery/bindings.dart';
import 'package:hydit/features/gallery/widget/shell.dart';
import 'package:hydit/features/settings/page/settings_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  await HiveStorage.init();

  await enableEdgeToEdge();
  await FlutterDisplayMode.setHighRefreshRate();
  await Permission.notification.request();

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


class GlobalBindings extends Bindings {
  //
  final Storage storage = HiveStorage();

  late final api = storage.api();

  @override
  void dependencies() => Get
    ..put(storage)
    ..put(api)
    ..put(VideoService())
    ..put(FileCache())
    ..put(TagRelationService());
}


class const App({super.key}) extends StatelessWidget {
  //
  @override
  Widget build(BuildContext context) {
    //
    final drawerKey = GlobalKey<InnerDrawerState>();

    final session = GallerySession();

    return GetMaterialApp(
      title: 'Hydit',
      debugShowCheckedModeBanner: false,
      theme: darkTheme(),
      initialRoute: '/',
      initialBinding: GlobalBindings(),
      defaultTransition: .rightToLeft,
      transitionDuration: transition,
      getPages: [
        GetPage(
          name: '/',
          curve: Curves.easeInOutCubic,
          binding: session.bindings,
          page: () => GalleryShell(
            session: session,
            drawerKey: drawerKey,
          ),
        ),
        GetPage(
          name: '/settings',
          page: () => Settings(),
          curve: Curves.easeInOutCubic,
          opaque: false,
        ),
      ],
    );
  }
}
