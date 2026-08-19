import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:media_kit/media_kit.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/entities/cache.dart';
import 'package:hydit/services/services.dart';

import 'package:hydit/features/gallery/bindings.dart';
import 'package:hydit/features/gallery/getx/selection.dart';
import 'package:hydit/features/gallery/page/gallery_page.dart';
import 'package:hydit/features/settings/page/settings_page.dart';

import 'package:hydit/widgets/drawer.dart';
import 'package:hydit/widgets/systems/gradient.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  await HiveStorage.init();

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
      ..put<Storage>(HiveStorage())
      ..put(Repo())
      ..put(VideoService())
      ..put(FileCache());
  }
}


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final tag = 'Gallery'.unique();
    final drawerKey = GlobalKey<InnerDrawerState>();

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
          binding: GalleryBindings(
            tag: tag,
            search: true,
          ),
          page: () => GalleryShell(
            tag: tag,
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


class GalleryShell extends StatelessWidget {
  final String tag;
  final GlobalKey<InnerDrawerState> drawerKey;

  const GalleryShell({
    super.key,
    required this.tag,
    required this.drawerKey,
  });

  bool dialog() {
    final SelectionController selection = Get.find(tag: tag);

    switch (selection.on) {
      case true:
        selection.clear();
        return false;
      case false:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      drawerKey: drawerKey,
      dialog: dialog,
      sidebar: Sidebar(
        tiles: [
          InboxTile(tag: tag),
          SettingsTile(tag: tag),
        ],
      ),
      child: Gallery(
        tag: tag,
        editor: true,
        swipeGesture: false,
        trailing: OnGradientIconButton(
          Symbols.dock_to_left,
          tooltip: 'Sidebar',
          onPressed: () => drawerKey.currentState!.toggle(),
        ),
      ),
    );
  }
}

