import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydrus_flutter/core/domain/entities_ext.dart';
import 'package:hydrus_flutter/features/search/getx/query.dart';


class TagPanel extends StatelessWidget {
  final VoidCallback? onTap;

  const TagPanel({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: .expand,
      children: [
        const PlaceholderText(),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: .symmetric(horizontal: 6),
            child: Row(
              spacing: 5,
              children: [
                SingleChildScrollView(
                  scrollDirection: .horizontal,
                  child: Obx(() {
                    return n.Wrap(buildChips())..spacing = 5;
                  }),
                ).niku..expanded,
                const TagPanelActions(),
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


class TagPanelActions extends StatelessWidget {
  const TagPanelActions({super.key});

  @override
  Widget build(BuildContext context) {
    final QueryController controller = Get.find();
    return Row(
      spacing: 4,
      children: [
        IconButton(
          tooltip: 'Clear tags',
          onPressed: controller.clearTags,
          icon: const Icon(Icons.clear),
        ),
        IconButton(
          onPressed: () {
            controller.add(controller.text);
            controller.clear();
          },
          icon: const Icon(Icons.arrow_drop_up),
          tooltip: 'Insert input as tag',
        ),
      ],
    );
  }
}
