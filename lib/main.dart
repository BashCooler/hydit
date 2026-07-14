import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:media_kit/media_kit.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:hydit/utils/theme.dart';
import 'package:hydit/services/repo.dart';
import 'package:hydit/services/video.dart';
import 'package:hydit/widgets/shell.dart';
import 'package:hydit/widgets/sidebar.dart';
import 'package:hydit/widgets/gradient.dart';

import 'package:hydit/features/gallery/bindings.dart';
import 'package:hydit/features/gallery/widget/menu_tiles.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('settings');

  await enableEdgeToEdge();
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
  @override
  void dependencies() {
    Get
      ..put(Repo(), permanent: true)
      ..put(VideoService(), permanent: true);
  }
}


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final drawerKey = GlobalKey<InnerDrawerState>();

    final trailing = OnGradientIconButton(
      Symbols.dock_to_left,
      tooltip: 'Sidebar',
      onPressed: () => drawerKey.currentState!.toggle(),
    );

    final page = GalleryPage()
        .withSearch()
        .withEditor()
        .trailing(trailing);

    final shell = AppShell(
      drawerKey: drawerKey,
      dialog: page.dialog,
      sidebar: Sidebar(
        tiles: [
          InboxTile(tag: page.tag),
          SettingsTile(tag: page.tag),
        ],
      ),
      child: page.build(),
    );

    return GetMaterialApp(
      title: 'Hydit',
      debugShowCheckedModeBanner: false,
      theme: darkTheme(),
      initialRoute: '/',
      initialBinding: GlobalBindings(),
      defaultTransition: .rightToLeft,
      transitionDuration: transition,
      opaqueRoute: false,
      getPages: [
        GetPage(
          name: '/',
          curve: Curves.easeInOutCubic,
          binding: GalleryBindings(page),
          page: () => shell,
        ),
      ],
    );
  }
}
