import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';

import '../getx/controller.dart';


class SettingsTextField extends HookWidget {
  final String label;
  final void Function(String) onChanged;
  final String? initial;

  const SettingsTextField({
    super.key,
    required this.label,
    required this.onChanged,
    this.initial,
  });

  void paste(TextEditingController controller) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) controller.text = data!.text!;
  }

  @override
  Widget build(BuildContext context) {
    final SettingsController settings = Get.find();
    final text = useTextEditingController(text: initial);

    final focus = useState(false);
    final node = useFocusNode();
    node.addListener(() => focus.value = node.hasFocus);

    return Obx(() => TextField(
      enabled: !settings.processing.value,
      onChanged: onChanged,
      onTapOutside: (_) => node.unfocus(),
      controller: text,
      focusNode: node,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: .always,
        suffixIcon: !focus.value ? const SizedBox.shrink() : Row(
          spacing: 5,
          mainAxisSize: .min,
          children: [
            IconButton(
              icon: const Icon(Icons.paste),
              onPressed: () => paste(text),
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => text.clear(),
            ),
          ],
        ),
      ),
    ));
  }
}