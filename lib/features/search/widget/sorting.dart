import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:hydit/api/enums.dart';
import 'package:hydit/utils/utils.dart';

import '../getx/query.dart';


class SortPopUp extends StatelessWidget {
  final String tag;

  const SortPopUp({super.key, required this.tag});

  QueryController? get query => maybeFind(tag: tag);

  @override
  Widget build(BuildContext context) {
    final query = this.query;

    if (query == null) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<FileSortType>(
      icon: const Icon(
        Symbols.sort,
        color: Colors.white,
        shadows: [
          Shadow(blurRadius: 16),
        ],
      ),
      onSelected: query.setSortType,
      itemBuilder: (BuildContext context) {
        return [
          ...FileSortType.values.map((option) {
            return PopupMenuItem<FileSortType>(
              value: option,
              child: CheckedPopUpChild(
                checked: query.options.sort == option,
                label: option.name,
              ),
            );
          }),

          const PopupMenuDivider(),

          PopupMenuItem(
            onTap: () => query.setSortAsc(true),
            child: CheckedPopUpChild(
              checked: query.options.asc,
              label: 'ascending',
            ),
          ),

          PopupMenuItem(
            onTap: () => query.setSortAsc(false),
            child: CheckedPopUpChild(
              checked: query.options.asc.not(),
              label: 'descending',
            ),
          ),
        ];
      },
    );
  }
}


class CheckedPopUpChild extends StatelessWidget {
  final bool checked;
  final String label;

  const CheckedPopUpChild({
    super.key,
    required this.checked,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        checked ? const Icon(Icons.check) : const Icon(null),
        label.n,
      ],
    );
  }
}

