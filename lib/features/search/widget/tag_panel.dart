import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import '../getx/query.dart';


class TagPanel extends StatelessWidget {
  final QueryController query;
  final VoidCallback? onTap;
  final Widget? actions;

  const TagPanel({
    super.key,
    required this.query,
    this.onTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: .expand,
      children: [
        PlaceholderText(query: query),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const .only(left: 6),
            child: Row(
              spacing: 5,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: .horizontal,
                    child: Obx(() {
                      return n.Wrap(buildChips())..spacing = 5;
                    }),
                  ),
                ),
                ?actions,
              ],
            ),
          ),
        ),
      ],
    ).niku..height = 48;
  }

  List<InputChip> buildChips() {
    return query.tags.map((tag) {
      return InputChip(
        label: tag.value.n,
        backgroundColor: tag.color,
        onDeleted: () => query.remove(tag),
      );
    }).toList();
  }
}


class PlaceholderText extends StatelessWidget {
  final QueryController query;

  const PlaceholderText({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .only(left: 16),
      child: Align(
        alignment: .centerLeft,
        child: Obx(() {
          if (query.tags.isNotEmpty) {
            return const SizedBox.shrink();
          }
          return 'No tags'.n..fontSize = 16;
        }),
      ),
    );
  }
}
