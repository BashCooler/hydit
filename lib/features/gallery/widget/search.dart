import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydrus_flutter/utils/theme.dart';
import 'package:hydrus_flutter/core/logic/entities.dart';
import 'package:hydrus_flutter/core/logic/entities_ext.dart';
import '../getx/controllers.dart';


class TagSearchBar extends StatefulWidget {
  const TagSearchBar({super.key});

  @override
  State<TagSearchBar> createState() => _TagSearchBarState();
}

class _TagSearchBarState extends State<TagSearchBar> {
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
    _queryController.suggestVisible.value = false;
    _queryController.textController.text = '';
    _queryController.searchForFiles();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlignVertical: .center,
      autofocus: true,
      focusNode: _focusNode,
      controller: _queryController.textController,
      decoration: InputDecoration(
        hintText: 'Enter tags here',
        filled: true,
        fillColor: Colors.transparent,
        suffixIcon: const _TagSearchBarActions(),
        border: .none,
      ),
      onSubmitted: (_) => _searchThenBack(),
      onTapOutside: (_) => setState(() => _focusNode.requestFocus()),
      onChanged: (q) => _queryController.onChange(q),
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
            queryController.suggestVisible.value = false;
          },
          icon: const Icon(Icons.clear),
          tooltip: 'Clear',
        ),
        IconButton(
          tooltip: 'Search',
          onPressed: () {
            queryController.suggestVisible.value = false;
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
      height: 48.0,
      child: Stack(
        fit: .expand,
        children: [
          Padding(
            padding: const .only(left: 16.0),
            child: Align(
              alignment: .centerLeft,
              child: Obx(() => queryController.tags.isNotEmpty
                  ? const SizedBox.shrink()
                  : Text('No tags', style: TextStyle(fontSize: 16))),
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
                  trailing ?? SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class Suggests extends StatelessWidget {
  const Suggests({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QueryController>();
    return Obx(() => ctrl.suggestVisible.value
        ? const _TagList()
        : const SizedBox.shrink());
  }
}


class _TagList extends StatelessWidget {
  const _TagList();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QueryController>();
    return Expanded(
      child: Material(
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: Scrollbar(
          thumbVisibility: true,
          thickness: 6,
          radius: .circular(3),
          child: Obx(() => ListView.builder(
            reverse: true,
            itemCount: ctrl.suggests.length,
            itemBuilder: (_, index) => _SearchEntry(index),
          )),
        ),
      ),
    );
  }
}

class _SearchEntry extends StatelessWidget {
  final int index;

  const _SearchEntry(this.index);

  @override
  Widget build(BuildContext context) {
    final queryController = Get.find<QueryController>();
    final tag = queryController.suggests[index];
    return ListTile(
      minTileHeight: AppTheme.fieldHeight,
      title: tag.label,
      trailing: Text(
        tag.count.toString(),
        style: TextStyle(color: tag.color, fontSize: 14.0),
      ),
      onTap: () {
        queryController.clear();
        queryController.addTag(tag);
      },
    );
  }
}