import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:hydit/widgets/shell.dart';
import 'package:media_kit/media_kit.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:hydit/widgets/sidebar.dart';
import 'features/gallery/getx/selection.dart';
import 'features/search/getx/query.dart';
import 'features/gallery/bindings.dart';
import 'features/settings/bindings.dart';
import 'services/repo.dart';
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
    final state = GlobalKey<InnerDrawerState>();

    final page = GalleryPage(state: state)
        .withSearch()
        .withEditor();

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
          binding: GalleryBindings(page),
          page: () => HomePage(page: page, state: state),
        ),
      ],
    );
  }
}


class HomePage extends StatelessWidget {
  final GalleryPage page;
  final GlobalKey<InnerDrawerState> state;

  const HomePage({super.key, required this.page, required this.state});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      ListTile(
        leading: const Icon(Icons.mail_outline),
        title: const Text("Inbox"),
        onTap: () {
          Get.find<SelectionController>(tag: page.tag)
             .clear();
          Get.find<QueryController>(tag: page.tag)
            ..clear()
            ..add('system:inbox')
            ..search();
          Get.back();
        },
      ),
      ListTile(
        leading: const Icon(Icons.settings),
        title: const Text('Settings'),
        onTap: () {
          Get.find<SelectionController>(tag: page.tag)
              .clear();
          SettingsPage().push();
        },
      ),
    ];

    return AppShell(
      state: state,
      dialog: page.dialog,
      sidebar: SideBar(tiles: tiles),
      child: page.build(),
    );
  }
}
