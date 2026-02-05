import 'dart:ui';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydrus_flutter/gallery/services.dart';
import 'package:hydrus_flutter/gallery/widgets/common.dart';
import 'package:hydrus_flutter/settings/theme.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppTheme.blackAlpha,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: BackdropFilter(
        filter: AppTheme.backdropFilter,
        child: AnimatedPadding(
          padding: .only(bottom: context.mediaQueryViewInsets.bottom),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: const Padding(
            padding: .all(AppTheme.searchPadding),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: .end,
                spacing: AppTheme.searchPadding,
                children: [
                  Suggests(),
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
          tooltip: 'Search',
          onPressed: () {
            queryController.visible.value = false;
            queryController.textController.text = '';
            queryController.searchForFiles();
            Get.back();
          },
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }
}