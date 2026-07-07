import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/features/editor/widget/info.dart';

import '../getx/base.dart';


class ServiceDropdown extends StatelessWidget {
  const ServiceDropdown({super.key});

  TagManager get manager => Get.find();

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
            trailingIcon: DropdownTrailing(s),
          ),
      ],
      onSelected: (service) {
        if (service != null) manager.service = service;
      },
    );
  }
}


class DropdownTrailing extends StatelessWidget {
  final String service;

  const DropdownTrailing(this.service, {super.key});

  TagManager get manager => Get.find();

  @override
  Widget build(BuildContext context) {
    final count = manager.length(service);

    return Row(
      mainAxisSize: .min,
      mainAxisAlignment: .spaceBetween,
      children: [
        Diff(service: service),
        if (count > 0) Badge(label: Text('$count')),
      ],
    );
  }
}

