import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:niku/extra/primitive.dart';

import 'package:hydit/utils/dictionaries.dart';

import '../getx/query.dart';


class SortPopUp extends StatelessWidget {
  final String tag;

  const SortPopUp({super.key, required this.tag});

  QueryController get query => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<FileSortType>(
      icon: const Icon(
        Symbols.sort,
        color: Colors.white,
        shadows: [
          Shadow(blurRadius: 16),
        ],
      ),
      onSelected: (value) => query.sortType = value,
      itemBuilder: (BuildContext context) {
        return [
          ...FileSortType.values.map((option) {
            return PopupMenuItem<FileSortType>(
              value: option,
              child: CheckedPopUpChild(
                checked: query.sortType == option,
                label: option.name,
              ),
            );
          }),

          const PopupMenuDivider(),

          PopupMenuItem(
            onTap: () => query.sortAsc = true,
            child: CheckedPopUpChild(
              checked: query.sortAsc,
              label: 'ascending',
            ),
          ),

          PopupMenuItem(
            onTap: () => query.sortAsc = false,
            child: CheckedPopUpChild(
              checked: !query.sortAsc,
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

