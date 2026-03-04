import 'package:get/get.dart';
import 'package:nil/nil.dart';
import 'package:flutter/material.dart';

import 'package:hydrus_flutter/utils/theme.dart';
import 'package:hydrus_flutter/core/logic/entities.dart';
import '../getx/controllers.dart';


class TagSearchBar extends StatefulWidget {
  const TagSearchBar({super.key});

  @override
  State<TagSearchBar> createState() => _TagSearchBarState();
}

class _TagSearchBarState extends State<TagSearchBar>
    with SingleTickerProviderStateMixin {
  final _focusNode = FocusNode();
  final _queryController = Get.find<QueryController>();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _searchThenBack() {
    if (_queryController.tags.isEmpty) {
      _queryController.addTag(Tag(_queryController.textController.text));
    }
    _queryController.visible.value = false;
    _queryController.textController.text = '';
    _queryController.searchForFiles();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: .circular(AppTheme.radius),
      child: Material(
        color: AppColors.blackWithAlpha,
        child: SizedBox(
          height: AppTheme.fieldHeight,
          child: TextField(
            autofocus: true,
            focusNode: _focusNode,
            controller: _queryController.textController,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radius),
                borderSide: BorderSide(
                  width: 2,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              hintText: 'Enter tags here',
              fillColor: AppColors.blackWithAlpha,
              suffixIcon: const _TagSearchBarActions(),
            ),
            onSubmitted: (_) => _searchThenBack(),
            onTapOutside: (_) => setState(() => _focusNode.requestFocus()),
            onChanged: (q) => _queryController.onChange(q),
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
          onPressed: () {
            queryController.textController.text = '';
            queryController.visible.value = false;
          },
          icon: const Icon(Icons.clear),
          tooltip: 'Clear',
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
        const VerticalDivider(width: 0.0),
      ],
    );
  }
}


class TagPanel extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget? trailing;

  const TagPanel({super.key, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    final queryController = Get.find<QueryController>();
    return SizedBox(
      height: AppTheme.fieldHeight,
      child: Card.outlined(
        color: AppColors.blackWithAlpha,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: .expand,
          children: [
            Padding(
              padding: const .only(left: AppTheme.outerPadding),
              child: Align(
                alignment: .centerLeft,
                child: Obx(() {
                  final tags = queryController.tags;
                  if (tags.isEmpty) {
                    return const Text('No tags', style: TextStyle(fontSize: 16),
                    );
                  } else {
                    return nil;
                  }
                }),
              ),
            ),
            InkWell(
              onTap: onTap,
              child: Padding(
                padding: const .symmetric(horizontal: 6.0),
                child: Row(
                  spacing: 5.0,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: .horizontal,
                        child: Obx(() => Wrap(
                          spacing: 5.0,
                          children: [
                            for (final tag in queryController.tags) InputChip(
                              label: Text(tag.value),
                              backgroundColor: tag.color,
                              onDeleted: () => queryController.removeTag(tag),
                            ),
                          ],
                        )),
                      ),
                    ),
                    trailing ?? nil,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class Suggests extends StatelessWidget {
  const Suggests({super.key});

  @override
  Widget build(BuildContext context) {
    final queryController = Get.find<QueryController>();
    return Obx(() => !queryController.visible.value ? nil : Expanded(
      child: Obx(() => Material(
        borderRadius: AppTheme.borderRadius,
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: ListView.builder(
          reverse: true,
          itemCount: queryController.suggests.length,
          itemBuilder: (_, index) => SearchEntry(index),
        ),
      )),
    ));
  }
}

class SearchEntry extends StatelessWidget {
  final int index;

  const SearchEntry(this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    final queryController = Get.find<QueryController>();
    final suggest = queryController.suggests[index];
    final tag = Tag(suggest.value);
    return ListTile(
      minTileHeight: AppTheme.fieldHeight,
      title: Text(tag.value, style: TextStyle(color: tag.color)),
      trailing: Text(
        suggest.count.toString(),
        style: TextStyle(color: tag.color, fontSize: 14.0),
      ),
      onTap: () {
        queryController.visible.value = false;
        queryController.textController.text = '';
        queryController.addTag(tag);
      },
    );
  }
}