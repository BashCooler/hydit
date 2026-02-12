import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydrus_flutter/gallery/services.dart';
import 'package:hydrus_flutter/settings/theme.dart';


class FrostedGlass extends StatelessWidget {
  final Widget child;

  const FrostedGlass({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        clipBehavior: Clip.hardEdge,
        borderRadius: AppTheme.borderRadius,
        child: BackdropFilter(
          filter: AppTheme.backdropFilter,
          child: child,
        ),
      ),
    );
  }
}


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
        color: AppTheme.blackAlpha,
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
            fillColor: AppTheme.blackAlpha,
            suffixIcon: const _TagSearchBarActions(),
          ),
          onSubmitted: (_) => _searchThenBack(),
          onTapOutside: (_) => setState(() => _focusNode.requestFocus()),
          onChanged: (q) => _queryController.onChange(q),
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
          onPressed: () {
            queryController.addTag(Tag(queryController.textController.text));
            queryController.textController.text = '';
            queryController.visible.value = false;
          },
          icon: const Icon(Icons.arrow_drop_up),
          tooltip: 'Insert as tag',
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
      height: AppTheme.listTileHeight,
      child: Card.outlined(
        color: AppTheme.blackAlpha,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: .expand,
          children: [
            Padding(
              padding: const .only(left: AppTheme.searchPadding),
              child: Align(
                alignment: .centerLeft,
                child: Obx(() {
                  final tags = queryController.tags;
                  if (tags.isEmpty) {
                    return const Text('No tags', style: TextStyle(fontSize: 16),
                    );
                  } else {
                    return const SizedBox.shrink();
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
                        child: Obx(() {
                          final tags = queryController.tags;
                          return Wrap(
                            spacing: 5.0,
                            children: [
                              for (final tag in tags) InputChip(
                                label: Text(tag.value),
                                backgroundColor: namespaceColors[tag.namespace]
                                    ?? namespaceColors['namespace'],
                                onDeleted: () => queryController.removeTag(tag),
                              )
                            ],
                          );
                        }),
                      ),
                    ),
                    trailing ?? const SizedBox.shrink(),
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
    return Obx(() => !queryController.visible.value
        ? const SizedBox.shrink()
        : Flexible(
      child: Obx(() => Material(
        borderRadius: AppTheme.borderRadius,
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: ListView.builder(
          reverse: true,
          itemCount: queryController.suggests.length,
          itemBuilder: (context, index) {
            final tag = queryController.suggests[index];
            return ListTile(
              minTileHeight: AppTheme.listTileHeight,
              title: Text(tag.value),
              trailing: Text(tag.count.toString()),
              onTap: () {
                queryController.visible.value = false;
                queryController.textController.text = '';
                queryController.addTag(Tag(tag.value));
              },
            );
          },
        ),
      )),
    ));
  }
}