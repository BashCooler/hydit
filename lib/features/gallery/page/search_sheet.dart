import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

import 'package:hydrus_flutter/core/ui/suggests.dart';
import 'package:hydrus_flutter/core/ui/tag_search.dart';
import 'package:hydrus_flutter/core/external/scroll_to_hide.dart';
import 'package:hydrus_flutter/utils/theme.dart';

import '../../../core/data/repo.dart';
import '../getx/query.dart';
import '../widget/tag_panel.dart';


void showSearchSheet(BuildContext context) {
  Get.find<ScrollToHideController>().hide();
  Get.find<Repo>().updateClient();
  log(Get.find<Repo>().api.host.toString());
  Navigator.push(
    context,
    ModalSheetRoute(
      swipeDismissible: true,
      viewportBuilder: (context, child) => SheetViewport(child: child),
      builder: (context) => SearchSheet(),
      transitionDuration: AppTheme.duration,
    ),
  );
}


class SearchSheet extends StatefulWidget {
  const SearchSheet({super.key});

  @override
  State<SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
  final QueryController controller = Get.find();

  void searchThenBack() {
    if (controller.tags.isEmpty) {
      controller.add(controller.text);
    }
    controller.clear();
    controller.searchForFiles();
    Get.back();
  }

  void onLeave(bool didPop, Object? result) {
    Future.delayed(AppTheme.duration, () {
      Get.find<ScrollToHideController>().show();
      Get.find<QueryController>().clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: onLeave,
      child: SheetKeyboardDismissible(
        dismissBehavior: const .onDragDown(isContentScrollAware: true),
        child: Sheet(
          child: Material(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: .end,
                children: [
                  Expanded(
                    child: Suggests(
                      onTap: (tag) => Get.find<QueryController>()
                        ..clear()
                        ..add(tag.raw),
                    ),
                  ),
                  const Divider(height: 1),
                  const TagPanel(),
                  TagSearchBar(
                    autofocus: true,
                    hintText: 'Enter tags here',
                    actions: const _TagSearchBarActions(),
                    onSubmitted: searchThenBack,
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


class _TagSearchBarActions extends StatelessWidget {
  const _TagSearchBarActions();

  @override
  Widget build(BuildContext context) {
    final queryController = Get.find<QueryController>();
    return Row(
      mainAxisSize: .min,
      spacing: 5.0,
      mainAxisAlignment: .end,
      children: [
        IconButton(
          onPressed: queryController.clear,
          icon: const Icon(Icons.clear),
          tooltip: 'Clear',
        ),
        IconButton(
          tooltip: 'Search',
          onPressed: () {
            queryController.clear();
            queryController.searchForFiles();
            Get.back();
          },
          icon: const Icon(Icons.search),
        ),
        const VerticalDivider(width: 0.0),
      ],
    );
  }
}