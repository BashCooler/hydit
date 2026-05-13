import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../getx/query.dart';


class TagSearchBar extends HookWidget {
  final bool enabled;
  final bool autofocus;
  final String? hintText;
  final Widget? actions;
  final void Function()? onSubmitted;
  final String? tag;

  const TagSearchBar({
    super.key,
    this.enabled = true,
    this.autofocus = false,
    this.hintText,
    this.actions,
    required this.onSubmitted,
    this.tag,
  });

  void keepFocus(FocusNode node) {
    node.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final node = useFocusNode();
    final QueryController query = Get.find(tag: tag);

    return TextField(
      enabled: enabled,
      textAlignVertical: .center,
      autofocus: autofocus,
      focusNode: node,
      controller: query.textController,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.transparent,
        suffixIcon: actions,
        border: .none,
      ),
      onChanged: (value) => query.query.value = value,
      onSubmitted: (_) => onSubmitted?.call(),
      onTapOutside: (_) => keepFocus(node),
    );
  }
}
