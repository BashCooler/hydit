import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

import 'package:hydrus_flutter/core/logic/entities_ext.dart';
import 'package:hydrus_flutter/core/ui/getx/controllers.dart';
import '../getx/page.dart';


void showTagSheet(BuildContext context) {
  Navigator.push(
    context,
    ModalSheetRoute(
      swipeDismissible: true,
      viewportBuilder: (context, child) => SheetViewport(child: child),
      builder: (context) => TagSheet(),
    ),
  );
}


class TagSheet extends StatelessWidget {
  const TagSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final index = Get.find<PageGetxController>().index.value;
    final service = Get.find<Images>().images[index].service;
    final namespaces = service.keys.toList();
    return SheetKeyboardDismissible(
      dismissBehavior: const .onDragDown(isContentScrollAware: true),
      child: Sheet(
        child: SafeArea(
          child: DefaultTabController(
            length: service.length,
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  TabBar(
                    isScrollable: true,
                    tabs: namespaces.map((n) => Tab(text: n)).toList(),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: namespaces.map((name) {
                        return ListView.builder(
                          itemCount: service[name]!.entries.length,
                          reverse: true,
                          shrinkWrap: true,
                          itemBuilder: (context, i) {
                            final tag = service[name]!.entries[i];
                            return ListTile(title: tag.label);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}