import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/core/services/executor.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/core/theme/theme.dart';
import 'package:hydit/core/services/repo.dart';
import 'package:hydit/core/widget/snack_bar.dart';
import 'package:hydit/features/gallery/getx/gallery.dart';
import 'package:hydit/features/search/widget/tag_panel.dart';

import '../getx/query.dart';
import '../getx/search.dart';
import '../widget/search.dart';
import '../widget/suggests.dart';
import '../widget/tag_actions.dart';


class Search extends StatefulWidget {
  final String tag;

  const Search({super.key, required this.tag});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final tagSearch = TagSearchController();
  final QueryController query = Get.find();

  @override
  void initState() {
    super.initState();
    verify();
  }

  void verify() async {
    final Repo repo = Get.find();

    final result = await Executor.run(() => repo.api.getVerifyAccessKey());

    switch (result) {
      case Failure(title: final title, message: final message):
        snackBar(const Icon(Icons.clear), title, message);
      case _:
        break;
    }
  }

  void searchThenBack() {
    if (query.tags.isEmpty) {
      query.add(tagSearch.text);
    }
    query.searchForFiles();
    Get.back();
  }

  void onLeave(bool didPop, Object? result) {
    Future.delayed(AppTheme.duration, () {
      final GalleryController gallery = Get.find(tag: widget.tag);
      gallery.showActions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: onLeave,
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
          scrolledUnderElevation: 0,
          title: Text('Search'),
        ),
        body: n.Column([
          Expanded(
            child: Suggests(
              tagSearchController: tagSearch,
              onTap: (tag) {
                tagSearch.clear();
                query.add(tag.raw);
              },
            ),
          ),
          const Divider(height: 1),
          TagPanel(
            actions: TagActions(
              onClear: query.clearTags,
              onInsert: () {
                query.add(tagSearch.text);
                tagSearch.clear();
              },
            ),
          ),
          TagSearchBar(
            autofocus: true,
            hintText: 'Enter tags here',
            tagSearchController: tagSearch,
            actions: TagActions(
              onClear: tagSearch.clear,
              onSearch: searchThenBack,
            ),
            onSubmitted: searchThenBack,
          ),
        ])
          ..mainAxisAlignment = .end
          ..safe,
      ),
    );
  }
}
