import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';

import 'package:hydit/widgets/drawer.dart';
import 'package:hydit/widgets/systems/gradient.dart';
import 'package:hydit/features/search/widget/sorting.dart';

import '../bindings.dart';
import '../page/gallery_page.dart';

import 'widgets.dart';


class GalleryShell extends StatelessWidget {
  final GallerySession session;
  final GlobalKey<InnerDrawerState> drawerKey;

  const GalleryShell({
    super.key,
    required this.session,
    required this.drawerKey,
  });

  GalleryBindings get bindings => session.bindings;

  bool dialog() {
    if (bindings.selection.off) {
      return true;
    }
    bindings.selection.clear();
    return false;
  }

  void showInbox() {
    bindings.selection.clear();
    session.query
      ..clear()
      ..add('system:inbox')
      ..search();
    Get.back();
  }

  void toSettings() {
    bindings.selection.clear();
    Get.toNamed('/settings');
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      drawerKey: drawerKey,
      dialog: dialog,
      sidebar: Sidebar(
        tiles: [
          InboxTile(onTap: showInbox),
          SettingsTile(onTap: toSettings),
        ],
      ),
      child: Gallery(
        bindings: bindings,
        editor: true,
        swipeGesture: false,
        loading: session.loading,
        appBarInfo: QueryInfo(query: session.query),
        fab: GalleryFAB(session: session),
        trailing: OnGradientIconButton(
          Symbols.dock_to_left,
          tooltip: 'Sidebar',
          onPressed: () => drawerKey.currentState!.toggle(),
        ),
        menuButton: SortPopUp(query: session.query),
        editButton: EditButton(
          bindings: bindings,
          loader: session.loader,
        ),
        onTileBuild: session.loader.next,
        onRefresh: () {
          return session.query.search(jumpUp: false);
        },
      ),
    );
  }
}
