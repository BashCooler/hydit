import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydrus_flutter/core/domain/entities_ext.dart';
import 'package:hydrus_flutter/features/gallery/getx/query.dart';


class TagPanel extends StatelessWidget {
  final VoidCallback? onTap;

  const TagPanel({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final QueryController controller = Get.find();
    return SizedBox(
      height: 48.0,
      child: Stack(
        fit: .expand,
        children: [
          Padding(
            padding: const .only(left: 16.0),
            child: Align(
              alignment: .centerLeft,
              child: Obx(() => controller.tags.isNotEmpty
                  ? const SizedBox.shrink()
                  : const Text('No tags', style: TextStyle(fontSize: 16))),
            ),
          ),
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const .symmetric(horizontal: 6.0),
              child: Row(
                spacing: 5.0,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: .horizontal,
                      child: Obx(() => Wrap(
                        spacing: 5.0,
                        children: [
                          for (final tag in controller.tags) InputChip(
                            label: Text(tag.value),
                            backgroundColor: tag.color,
                            onDeleted: () => controller.remove(tag),
                          ),
                        ],
                      )),
                    ),
                  ),
                  const _TagPanelActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _TagPanelActions extends StatelessWidget {
  const _TagPanelActions();

  @override
  Widget build(BuildContext context) {
    final QueryController controller = Get.find();
    return Row(
      spacing: 4.0,
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