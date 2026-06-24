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
    final length = manager.lengthOf(service);
    switch (length) {
      case 0:
        return Tab(text: manager.pretty(service));
      case _:
        return n.Row([
          Tab(text: manager.pretty(service)),
          Badge(label: '${manager.lengthOf(service)}'.n),
        ])
          ..gap = 5;
    }
  }

  TagManager get manager => Get.find();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        return DefaultTabController(
          initialIndex: manager.index,
          length: manager.services.length,
          child: Column(
            children: [
              const Expanded(child: Up()),
              const Divider(height: 1),
              TabBar(
                isScrollable: true,
                tabAlignment: .center,
                onTap: manager.selectServiceByIndex,
                tabs: getTabs(manager),
              ),
              SizedBox(
                height: 55 * 3,
                child: Down(tag: tag),
              ),
            ],
          ),
        );
      }),
    );
  }
}
