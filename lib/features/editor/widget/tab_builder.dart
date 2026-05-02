import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../getx/tags.dart';
import 'split_view.dart';


class TabBuilder extends StatelessWidget {
  const TabBuilder({super.key});

  List<Widget> getTabs(TagManager manager) => manager.services
      .map((service) => Tab(text: manager.pretty(service)))
      .toList();

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
                const EditorSplitView(),
              ],
            ),
          );
        },
      ),
    );
  }
}