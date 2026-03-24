import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydrus_flutter/features/gallery/getx/query.dart';


class TagSearchBar extends StatefulWidget {
  final bool? autofocus;
  final String? hintText;
  final Widget? actions;
  final void Function() onSubmitted;

  const TagSearchBar({
    super.key,
    this.autofocus,
    this.hintText,
    this.actions,
    required this.onSubmitted,
  });

  @override
  State<TagSearchBar> createState() => _TagSearchBarState();
}

class _TagSearchBarState extends State<TagSearchBar> {
  final _focusNode = FocusNode();
  final QueryController controller = Get.find();

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
      textAlignVertical: .center,
      autofocus: widget.autofocus ?? false,
      focusNode: _focusNode,
      controller: controller.$,
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: true,
        fillColor: Colors.transparent,
        suffixIcon: widget.actions,
        border: .none,
      ),
      onChanged: controller.onChange,
      onSubmitted: (_) => widget.onSubmitted(),
      onTapOutside: keepFocus,
    );
  }
}