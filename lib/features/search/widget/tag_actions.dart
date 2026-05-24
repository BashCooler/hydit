import 'package:flutter/material.dart';


class TagActions extends StatelessWidget {
  final void Function()? onClear;
  final void Function()? onInsert;
  final void Function()? onSearch;

  const TagActions({
    super.key,
    this.onClear,
    this.onInsert,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      spacing: 5,
      mainAxisAlignment: .end,
      children: [
        if (onClear != null) IconButton(
          onPressed: onClear,
          icon: const Icon(Icons.clear),
          tooltip: 'Clear',
        ),
        if (onInsert != null) IconButton(
          tooltip: 'Insert input as tag',
          icon: const Icon(Icons.arrow_drop_up),
          onPressed: onInsert,
        ),
        if (onSearch != null) IconButton(
          tooltip: 'Search',
          onPressed: onSearch,
          icon: const Icon(Icons.search),
        ),
        const VerticalDivider(width: 0),
      ],
    );
  }
}