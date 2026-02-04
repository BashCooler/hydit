import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydrus_flutter/gallery/gallery.dart';
import 'package:hydrus_flutter/gallery/services.dart';
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
      backgroundColor: Consts.blackAlpha,
      // appBar: AppBar(backgroundColor: Colors.transparent),
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: Consts.blur, sigmaY: Consts.blur),
        child: AnimatedPadding(
          padding: EdgeInsetsGeometry.only(
            bottom: context.mediaQueryViewInsets.bottom,
          ),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: Padding(
            padding: EdgeInsetsGeometry.all(Consts.searchPadding),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: .end,
                spacing: Consts.searchPadding,
                children: [
                  Suggests(),
                  TagPanel(clickable: false),
                  LiquidSearchBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class LiquidSearchBar extends StatefulWidget {
  const LiquidSearchBar({super.key});

  @override
  State<LiquidSearchBar> createState() => _LiquidSearchBarState();
}

class _LiquidSearchBarState extends State<LiquidSearchBar>
    with SingleTickerProviderStateMixin {
  final _focusNode = FocusNode();
  final _queryController = Get.find<QueryController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(Consts.radius),
      child: TextField(
        autofocus: true,
        focusNode: _focusNode,
        controller: _queryController.textController,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Consts.radius),
            borderSide: BorderSide(
              width: 2,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          hintText: 'Enter tags here',
          fillColor: Consts.blackAlpha,
          suffixIcon: Row(
              mainAxisSize: .min,
              spacing: 5.0,
              mainAxisAlignment: .end,
              children: [
                IconButton(
                  onPressed: () {
                    _queryController.textController.text = '';
                    _queryController.visible.value = false;
                  },
                  icon: Icon(Icons.clear),
                  tooltip: 'Clear',
                ),
                IconButton(
                  onPressed: () {
                    final tag = _queryController.textController.text;
                    _queryController.textController.text = '';
                    _queryController.addTag(Tag(tag));
                  },
                  icon: Icon(Icons.arrow_drop_up),
                  tooltip: 'Insert as tag',
                ),
                VerticalDivider(width: 0.0),
              ]
          ),
        ),
        onSubmitted: (s) {
          _queryController.visible.value = false;
          _queryController.textController.text = '';
          _queryController.searchForFiles();
          Get.back();
        },
        onTapOutside: (_) => setState(() => _focusNode.requestFocus()),
        onChanged: (q) => _queryController.onChange(q),
        onTap: () {
          final q = _queryController.textController.text;
          _queryController.onChange(q);
        },
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
        borderRadius: BorderRadius.circular(Consts.radius),
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: ListView.builder(
          reverse: true,
          itemCount: queryController.suggests.length,
          itemBuilder: (context, index) {
            final tag = queryController.suggests[index];
            return ListTile(
              minTileHeight: Consts.listTileHeight,
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
    )
    );
  }
}
