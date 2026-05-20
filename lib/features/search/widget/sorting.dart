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
              child: Row(
                spacing: 10,
                children: [
                  query.sortType == option
                      ? const Icon(Icons.check)
                      : const Icon(null),
                  option.name.n,
                ],
              ),
            );
          }),

          const PopupMenuDivider(),

          PopupMenuItem(
            onTap: () {
              query.sortAsc.value = true;
              query.searchForFiles();
            },
            child: Row(
              spacing: 10,
              children: [
                query.sortAsc.value
                    ? const Icon(Icons.check)
                    : const Icon(null),
                'ascending'.n,
              ],
            ),
          ),

          PopupMenuItem(
            onTap: () {
              query.sortAsc.value = false;
              query.searchForFiles();
            },
            child: Row(
              spacing: 10,
              children: [
                !query.sortAsc.value
                    ? const Icon(Icons.check)
                    : const Icon(null),
                'descending'.n,
              ],
            ),
          ),
        ];
      },
    );
  }
}