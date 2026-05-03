import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:scroll_to_hide/scroll_to_hide.dart';

import 'package:hydrus_flutter/utils/theme.dart';
import 'package:hydrus_flutter/core/data/repo.dart';
import 'package:hydrus_flutter/features/search/getx/query.dart';
import 'package:hydrus_flutter/features/search/widget/search.dart';
import 'package:hydrus_flutter/features/search/widget/suggests.dart';

import '../widget/tag_panel.dart';


void showSearchSheet(BuildContext context) {
  Get.find<ScrollToHideController>().hide();
  Get.find<Repo>().updateClient();
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
  final QueryController query = Get.find();

  static const behaviour = SheetKeyboardDismissBehavior
      .onDragDown(isContentScrollAware: true);

  void searchThenBack() {
    if (query.tags.isEmpty) {
      query.add(query.text);
    }
    query..clear()..searchForFiles();
    Get.back();
  }

  void onLeave(bool didPop, Object? result) {
    Future.delayed(AppTheme.duration, () {
      Get.find<ScrollToHideController>().show();
      query.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: onLeave,
      child: SheetKeyboardDismissible(
        dismissBehavior: behaviour,
        child: Sheet(
          child: Material(
            child: n.Column([
              Suggests(
                onTap: (tag) {
                  query
                    ..clear()
                    ..add(tag.raw);
                },
              ).niku
                ..expanded,
              const Divider(height: 1),
              const TagPanel(),
              TagSearchBar(
                autofocus: true,
                hintText: 'Enter tags here',
                actions: const _TagSearchBarActions(),
                onSubmitted: searchThenBack,
              ),
            ])
              ..mainAxisAlignment = .end
              ..safe,
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
    final QueryController query = Get.find();
    return Row(
      mainAxisSize: .min,
      spacing: 5.0,
      mainAxisAlignment: .end,
      children: [
        IconButton(
          onPressed: query.clear,
          icon: const Icon(Icons.clear),
          tooltip: 'Clear',
        ),
        IconButton(
          tooltip: 'Search',
          onPressed: () {
            query
              ..clear()
              ..searchForFiles();
            Get.back();
          },
          icon: const Icon(Icons.search),
        ),
        const VerticalDivider(width: 0),
      ],
    );
  }
}