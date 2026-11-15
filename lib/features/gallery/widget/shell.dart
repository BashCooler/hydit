import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';

import 'package:hydit/widgets/drawer.dart';
import 'package:hydit/widgets/systems/gradient.dart';
import 'package:hydit/features/search/getx/query.dart';
import 'package:hydit/features/search/widget/sorting.dart';

import '../bindings.dart';
import '../getx/loader.dart';
import '../page/gallery_page.dart';

import 'widgets.dart';


class GalleryShell extends StatelessWidget {
  final GalleryBindings bindings;
  final GlobalKey<InnerDrawerState> drawerKey;

  const GalleryShell({
    super.key,
    required this.bindings,
    required this.drawerKey,
  });

  bool dialog() {
    if (bindings.selection.off) {
      return true;
    }
    bindings.selection.clear();
    return false;
  }

  void showInbox() {
    bindings.selection.clear();
    Get.find<QueryController>(tag: bindings.tag)
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
    //
    final query = Get.find<QueryController>(tag: bindings.tag);

    final loader = Get.find<Loader>(tag: bindings.tag);

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
        appBarInfo: QueryInfo(query: query),
        fab: GalleryFAB(tag: bindings.tag),
        trailing: OnGradientIconButton(
          Symbols.dock_to_left,
          tooltip: 'Sidebar',
          onPressed: () => drawerKey.currentState!.toggle(),
        ),
        menuButton: SortPopUp(query: query),
        onTileBuild: loader.next,
        onRefresh: query.search,
      ),
    );
  }
}
