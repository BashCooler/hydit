import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

import 'package:hydrus_flutter/core/logic/entities.dart';
import 'package:hydrus_flutter/core/logic/entities_ext.dart';
import 'package:hydrus_flutter/core/ui/getx/controllers.dart';
import '../getx/controllers.dart';


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
    final index = Get.find<PageViewController>().currentIndex.value;
    final tags = Get.find<Images>().images[index].tags;
    final namespaces = tags.keys.toList();
    return SheetKeyboardDismissible(
      dismissBehavior: const .onDragDown(isContentScrollAware: true),
      child: Sheet(
        child: SafeArea(
          child: DefaultTabController(
            length: tags.length,
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
                      children: namespaces.map((n) {
                        return ListView.builder(
                          itemCount: tags[n].length ?? 0,
                          reverse: true,
                          shrinkWrap: true,
                          itemBuilder: (context, i) {
                            final tag = Tag(tags[n][i]);
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