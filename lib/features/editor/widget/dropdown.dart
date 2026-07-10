import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/features/editor/widget/info.dart';

import '../getx/base.dart';


class ServiceDropdown extends StatelessWidget {
  final String tag;

  const ServiceDropdown({super.key, required this.tag});

  TagManager get manager => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      width: Get.width,
      initialSelection: manager.service,
      expandedInsets: const .symmetric(horizontal: 7.5),
      enableSearch: false,
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        isCollapsed: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: .circular(12.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
        contentPadding: const .only(left: 12),
      ),
      dropdownMenuEntries: [
        for (final s in manager.services)
          DropdownMenuEntry<String>(
            value: s,
            label: s,
            trailingIcon: Obx(() => DropdownTrailing(
              tag: tag,
              service: s,
              count: manager.length(s),
            )),
          ),
      ],
      onSelected: (service) {
        if (service != null) manager.service = service;
      },
    );
  }
}


class DropdownTrailing extends StatelessWidget {
  final String tag;
  final int count;
  final String service;

  const DropdownTrailing({
    super.key,
    required this.tag,
    required this.count,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      mainAxisAlignment: .spaceBetween,
      children: [
        Diff(tag: tag, service: service),
        if (count > 0) Badge(label: Text('$count')),
      ],
    );
  }
}

