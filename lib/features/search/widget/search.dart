import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../getx/tag_search.dart';


class TagSearchBar extends HookWidget {
  final bool enabled;
  final bool autofocus;
  final String? hintText;
  final Widget? actions;
  final void Function()? onSubmitted;
  final TagSearchController tagSearchController;

  const TagSearchBar({
    super.key,
    this.enabled = true,
    this.autofocus = false,
    this.hintText,
    this.actions,
    required this.onSubmitted,
    required this.tagSearchController,
  });

  void keepFocus(FocusNode node) {
    node.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final node = useFocusNode();

    return TextField(
      enabled: enabled,
      textAlignVertical: .center,
      autofocus: autofocus,
      focusNode: node,
      controller: tagSearchController.controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.transparent,
        suffixIcon: actions,
        border: .none,
      ),
      onChanged: tagSearchController.query,
      onSubmitted: (_) => onSubmitted?.call(),
      onTapOutside: (_) => keepFocus(node),
    );
  }
}
