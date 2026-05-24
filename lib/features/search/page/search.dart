import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/utils/theme.dart';
import 'package:hydit/core/data/repo.dart';
import 'package:hydit/core/ui/snack_bar.dart';
import 'package:hydit/features/gallery/getx/gallery.dart';
import 'package:hydit/features/search/widget/tag_panel.dart';

import '../getx/query.dart';
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
  final QueryController query = Get.find();

  @override
  void initState() {
    super.initState();
    verify();
  }

  void verify() async {
    final Repo repo = Get.find();
    final result = await repo.verify();
    showErrorOrSuccess(result, success: false);
  }

  void searchThenBack() {
    if (query.tags.isEmpty) {
      query.add(query.text);
    }
    query..clear()..searchForFiles();
    Get.back();
  }

  void onLeave(bool didPop, Object? result) {
    Future.delayed(AppTheme.duration, () {
      final GalleryController gallery = Get.find(tag: widget.tag);
      gallery.showActions();
      query.clear();
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
          Suggests(onTap: (tag) => query..clear()..add(tag.raw)).niku
            ..expanded,
          const Divider(height: 1),
          const TagPanel(),
          TagSearchBar(
            autofocus: true,
            hintText: 'Enter tags here',
            actions: TagActions(
              onClear: query.clear,
              onSearch: () {
                query..clear()..searchForFiles();
                Get.back();
              },
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
