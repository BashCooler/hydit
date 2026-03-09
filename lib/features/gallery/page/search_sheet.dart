import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydrus_flutter/core/logic/entities.dart';
import 'package:hydrus_flutter/core/ui/widget/scroll_to_hide.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

import '../getx/controllers.dart';
import '../widget/search.dart';


void showSearchSheet(BuildContext context) {
  Get.find<ScrollToHideController>().hide();
  Navigator.push(
    context,
    ModalSheetRoute(
      swipeDismissible: true,
      viewportBuilder: (context, child) => SheetViewport(child: child),
      builder: (context) => SearchSheet(),
    ),
  );
}


class SearchSheet extends StatefulWidget {
  const SearchSheet({super.key});

  @override
  State<SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, _) =>
          Get.find<ScrollToHideController>().show(),
      child: const SheetKeyboardDismissible(
        dismissBehavior: .onDragDown(isContentScrollAware: true),
        child: Sheet(
          child: Material(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: .end,
                children: [
                  Suggests(),
                  Divider(height: 1),
                  TagPanel(trailing: _TagPanelActions()),
                  TagSearchBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _TagPanelActions extends StatelessWidget {
  const _TagPanelActions();

  @override
  Widget build(BuildContext context) {
    final queryController = Get.find<QueryController>();
    return Row(
      spacing: 4.0,
      children: [
        IconButton(
          tooltip: 'Clear tags',
          onPressed: () => queryController.clearTags(),
          icon: const Icon(Icons.clear),
        ),
        IconButton(
          onPressed: () {
            queryController.addTag(Tag(queryController.textController.text));
            queryController.textController.text = '';
            queryController.suggestVisible.value = false;
          },
          icon: const Icon(Icons.arrow_drop_up),
          tooltip: 'Insert input as tag',
        ),
      ],
    );
  }
}