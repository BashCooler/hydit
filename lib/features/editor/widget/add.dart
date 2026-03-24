import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydrus_flutter/features/gallery/getx/controllers.dart';


class TagSearchBar extends StatefulWidget {
  const TagSearchBar({super.key});

  @override
  State<TagSearchBar> createState() => _TagSearchBarState();
}

class _TagSearchBarState extends State<TagSearchBar> {
  final _focusNode = FocusNode();
  final QueryController _queryController = Get.find();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // void _searchThenBack() {
  //   if (_queryController.tags.isEmpty) {
  //     _queryController.addTag(Tag(_queryController.textController.text));
  //   }
  //   _queryController.suggestVisible.value = false;
  //   _queryController.textController.text = '';
  //   _queryController.searchForFiles();
  //   Get.back();
  // }

  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlignVertical: .center,
      autofocus: false,
      focusNode: _focusNode,
      controller: _queryController.textController,
      decoration: InputDecoration(
        hintText: 'Add tags',
        filled: true,
        fillColor: Colors.transparent,
        // suffixIcon: const _TagSearchBarActions(),
        border: .none,
      ),
      // onSubmitted: (_) => _searchThenBack(),
      onTapOutside: (_) => setState(() => _focusNode.requestFocus()),
      onChanged: (q) => _queryController.onChange(q),
    );
  }
}