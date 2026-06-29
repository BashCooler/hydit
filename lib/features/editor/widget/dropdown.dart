import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../getx/tags.dart';


class ServiceDropdown extends HookWidget {
  final String tag;
  final Future<bool> Function() callback;

  const ServiceDropdown({
    super.key,
    required this.tag,
    required this.callback,
  });

  TagManager get manager => Get.find();

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();

    return Obx(() {
      return DropdownMenu<String>(
        controller: controller,
        width: Get.width,
        initialSelection: manager.service.value,
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
        onSelected: (service) async {
          controller.text = manager.service.value;
          if (service == null || !await callback()) {
            return;
          }
          manager.select(service);
        },
      );
    });
  }
}


class DropdownTrailing extends StatelessWidget {
  final String service;

  const DropdownTrailing(this.service, {super.key});

  TagManager get manager => Get.find();

  @override
  Widget build(BuildContext context) {
    final count = manager.length(service);

    if (count < 1) {
      return const SizedBox.shrink();
    }

    return Badge(
      label: Text('$count'),
    );
  }
}

