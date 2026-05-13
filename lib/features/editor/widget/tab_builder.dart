import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import '../getx/tags.dart';
import 'split_view.dart';


class TabBuilder extends StatelessWidget {
  final String tag;

  const TabBuilder({super.key, required this.tag});

  List<Widget> getTabs(TagManager manager) => manager.services
      .map((service) => buildTab(manager, service))
      .toList();

  Widget buildTab(TagManager manager, String service) {
    final length = manager.length(service);
    switch (length) {
      case 0:
        return Tab(text: manager.pretty(service));
      case _:
        return n.Row([
          Tab(text: manager.pretty(service)),
          Badge(label: '${manager.length(service)}'.n),
        ])
          ..gap = 5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GetBuilder(
        init: Get.find<TagManager>(),
        builder: (manager) {
          return DefaultTabController(
            initialIndex: manager.index,
            length: manager.services.length,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabAlignment: .center,
                  onTap: manager.selectServiceByIndex,
                  tabs: getTabs(manager),
                ),
                EditorSplitView(tag: tag),
              ],
            ),
          );
        },
      ),
    );
  }
}