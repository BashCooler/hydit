import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/widgets/tag_list.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hydit/utils/utils.dart';

import '../getx/query.dart';
import '../getx/tag_search.dart';
import '../widget/search.dart';
import '../widget/suggests.dart';
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
    final scrollUp = useScrollController();
    final scrollDown = useScrollController();

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        scrolledUnderElevation: 0,
        title: const Text('Search'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 55 * 3,
              child: Obx(() {
                return TagList(
                  tags: query.tags.toList(),
                  reverse: true,
                  scrollController: scrollUp,
                  itemBuilder: (context, tag) {
                    return TagTile(
                      tag: tag,
                      trailing: const Icon(Icons.remove),
                      onTap: query.remove,
                    );
                  },
                );
              }),
            ),

            const Divider(height: 1),

            Expanded(
              child: Suggests(
                tagSearchController: search,
                scrollController: scrollDown,
                itemBuilder: (context, tag) => TagTile(
                  tag: tag,
                  trailing: TagCount(tag: tag, count: tag.count ?? 0),
                  onTap: (tag) {
                    search.clear();
                    query.add(tag.raw);
                  },
                  onLongPress: copyTag,
                ),
              ),
            ),

            const Divider(height: 1),

            TagSearchBar(
              autofocus: true,
              hintText: 'Enter tags here',
              tagSearchController: search,
              actions: TagActions(
                onClear: search.clear,
                onInsert: () => query.add(search.text),
                onSearch: () => searchThenBack(search.text),
              ),
              onSubmitted: () => searchThenBack(search.text),
            ),
          ],
        ),
      ),
    );
  }
}
