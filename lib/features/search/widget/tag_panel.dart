import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/core/entity/tag.dart';
import 'package:hydit/utils/theme.dart';
import 'package:hydit/features/search/getx/query.dart';


class TagPanel extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget? actions;

  const TagPanel({super.key, this.onTap, this.actions});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: .expand,
      children: [
        const PlaceholderText(),
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

    return Padding(
      padding: const .only(left: 16),
      child: Align(
        alignment: .centerLeft,
        child: Obx(() {
          if (controller.tags.isNotEmpty) {
            return const SizedBox.shrink();
          }
          return 'No tags'.n..fontSize = 16;
        }),
      ),
    );
  }
}


extension TagUI on Tag {
  Color? get color =>
      namespaceColors[namespace] ?? namespaceColors['namespace'];
}
