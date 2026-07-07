import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:niku/namespace.dart' as n;
import 'package:hydit/widgets/tag_list.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../getx/query.dart';
import '../getx/tag_search.dart';
import '../widget/search.dart';
import '../widget/suggests.dart';
import '../widget/tag_panel.dart';
import '../widget/tag_actions.dart';


class Search extends HookWidget {
  final QueryController query;

  const Search({super.key, required this.query});

  void searchThenBack(String entry) {
    if (query.tags.isEmpty) query.add(entry);
    query.search();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final search = useMemoized(() => TagSearchController());

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        scrolledUnderElevation: 0,
        title: Text('Search'),
      ),
      body: n.Column([
        Expanded(
          child: Suggests(
            tagSearchController: search,
            itemBuilder: (context, tag) => TagTile(
              tag: tag,
              trailing: tag.count?.toString().n
                ?..color = tag.color
                ..fontSize = 14,
              onTap: (tag) {
                search.clear();
                query.add(tag.raw);
              },
              onLongPress: (tag) {
                Clipboard.setData(ClipboardData(text: tag.raw));
              },
            ),
          ),
        ),
        const Divider(height: 1),
        TagPanel(
          query: query,
          actions: TagActions(
            onClear: query.clear,
            onInsert: () {
              query.add(search.text);
              search.clear();
            },
          ),
        ),
        TagSearchBar(
          autofocus: true,
          hintText: 'Enter tags here',
          tagSearchController: search,
          actions: TagActions(
            onClear: search.clear,
            onSearch: () => searchThenBack(search.text),
          ),
          onSubmitted: () => searchThenBack(search.text),
        ),
      ])
        ..mainAxisAlignment = .end
        ..safe,
    );
  }
}
