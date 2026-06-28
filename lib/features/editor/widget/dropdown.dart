import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/features/editor/getx/tags.dart';
import 'package:hydit/features/viewer/getx/page.dart';
import 'package:hydit/reactive/file_store.dart';


class ServiceDropdown extends HookWidget {
  final String tag;
  final Future<bool> Function() callback;

  const ServiceDropdown({
    super.key,
    required this.tag,
    required this.callback,
  });

  TagManager get manager => Get.find();
  FileStore get files => Get.find(tag: tag);
  PageGetxController get page => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final current = useState(manager.service.value);

    return DropdownMenu<String>(
      controller: controller,
      width: Get.width,
      initialSelection: current.value,
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
          DropdownMenuEntry<String>(value: s, label: s),
      ],
      onSelected: (service) async {
        controller.text = current.value;
        if (service == null || !await callback()) {
          return;
        }
        current.value = service;
        manager.init(files[page.i], service);
      },
    );
  }
}
