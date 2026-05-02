import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydrus_flutter/features/gallery/getx/query.dart';


class TagSearchBar extends StatefulWidget {
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

  @override
  State<TagSearchBar> createState() => _TagSearchBarState();
}

class _TagSearchBarState extends State<TagSearchBar> {
  final _focusNode = FocusNode();
  late final QueryController query;

  @override
  void initState() {
    super.initState();
    query = Get.find(tag: widget.tag);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void keepFocus(PointerDownEvent event) {
    setState(() => _focusNode.requestFocus());
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: widget.enabled,
      textAlignVertical: .center,
      autofocus: widget.autofocus,
      focusNode: _focusNode,
      controller: query.textController,
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: true,
        fillColor: Colors.transparent,
        suffixIcon: widget.actions,
        border: .none,
      ),
      onChanged: query.onChange,
      onSubmitted: (_) => widget.onSubmitted?.call(),
      onTapOutside: keepFocus,
    );
  }
}