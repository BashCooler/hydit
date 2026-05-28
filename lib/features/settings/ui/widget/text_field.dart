import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:niku/namespace.dart' as n;
import 'package:flutter_hooks/flutter_hooks.dart';

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

  @override
  Widget build(BuildContext context) {
    final SettingsController settings = Get.find();
    final text = useTextEditingController(text: initial);

    final focus = useState(false);
    final node = useFocusNode();
    node.addListener(() => focus.value = node.hasFocus);

    return n.Column([
      n.Text(label)..fontSize = 16.5,
      Obx(() {
        return TextField(
          enabled: !settings.processing.value,
          onChanged: onChanged,
          onTapOutside: (_) => node.unfocus(),
          controller: text,
          focusNode: node,
          textAlignVertical: .center,
          decoration: InputDecoration(
            contentPadding: const .symmetric(vertical: 0, horizontal: 8),
            border: OutlineInputBorder(
              borderSide: .none,
              borderRadius: .circular(8.0),
            ),
            floatingLabelBehavior: .always,
            filled: true,
            suffixIcon: !focus.value
                ? const SizedBox.shrink()
                : Actions(text: text),
          ),
        );
      }),
    ])
      ..crossAxisAlignment = .start
      ..gap = 4
      ..padding = const .symmetric(horizontal: 24);
  }
}


class Actions extends StatelessWidget {
  final TextEditingController text;

  const Actions({super.key, required this.text});

  void paste(TextEditingController controller) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) controller.text = data!.text!;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
