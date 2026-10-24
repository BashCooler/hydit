import 'package:flutter/material.dart';

import 'package:hydit/utils/theme.dart';


class const GenericListView<T>({
  super.key,
  final ScrollController? scrollController,
  required final List<T> items,
  final bool reverse = false,
  final bool shrinkWrap = false,
  required final Widget Function(BuildContext context, T item) itemBuilder,
}) extends StatelessWidget {
  //
  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Scrollbar(
          controller: scrollController,
          child: ListView.builder(
            reverse: reverse,
            itemCount: items.length,
            controller: scrollController,
            shrinkWrap: shrinkWrap,
            padding: Insets.listPadding,
            itemBuilder: (context, index) {
              return itemBuilder(context, items[index]);
            },
          ),
        ),
      ),
    );
  }
}
