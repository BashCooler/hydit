import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/core/domain/entities_ext.dart';
import 'package:hydit/features/search/getx/query.dart';

import 'tag_actions.dart';


class TagPanel extends StatelessWidget {
  final VoidCallback? onTap;

  const TagPanel({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final QueryController query = Get.find();
    return Stack(
      fit: .expand,
      children: [
        const PlaceholderText(),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: .only(left: 6),
            child: Row(
              spacing: 5,
              children: [
                SingleChildScrollView(
                  scrollDirection: .horizontal,
                  child: Obx(() {
                    return n.Wrap(buildChips())..spacing = 5;
                  }),
                ).niku..expanded,
                TagActions(
                  onClear: query.clearTags,
                  onInsert: () {
                    query.add(query.text);
                    query.clear();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    ).niku..height = 48;
  }

  List<InputChip> buildChips() {
    final QueryController controller = Get.find();
    return controller.tags.map((tag) {
      return InputChip(
        label: tag.value.n,
        backgroundColor: tag.color,
        onDeleted: () => controller.remove(tag),
      );
    }).toList();
  }
}


class PlaceholderText extends StatelessWidget {
  const PlaceholderText({super.key});

  @override
  Widget build(BuildContext context) {
    final QueryController controller = Get.find();

    return Align(
      alignment: .centerLeft,
      child: Obx(() {
        if (controller.tags.isNotEmpty) {
          return const SizedBox.shrink();
        }
        return 'No tags'.n..fontSize = 16;
      }),
    ).niku..padding = .only(left: 16);
  }
}
