import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/extra/primitive.dart';

import 'package:hydrus_flutter/utils/dictionaries.dart';

import '../getx/query.dart';


class SortPopUp extends StatelessWidget {
  const SortPopUp({super.key});

  @override
  Widget build(BuildContext context) {
    final query = Get.find<QueryController>();
    return PopupMenuButton<FileSortType>(
      icon: const Icon(
        Icons.sort,
        color: Colors.white,
        shadows: [
          Shadow(blurRadius: 16),
        ],
      ),
      onSelected: (value) {
        query.sortType = value;
        query.searchForFiles();
      },
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
            onTap: () {
              query.sortAsc.value = true;
              query.searchForFiles();
            },
            child: CheckedPopUpChild(
              checked: query.sortAsc.value,
              label: 'ascending',
            ),
          ),

          PopupMenuItem(
            onTap: () {
              query.sortAsc.value = false;
              query.searchForFiles();
            },
            child: CheckedPopUpChild(
              checked: !query.sortAsc.value,
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

