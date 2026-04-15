import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../getx/controller.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final settings = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const .all(15),
        child: Column(
          spacing: 15,
          children: [
            UrlOrKeyField(
              label: 'Url',
              onChanged: settings.updateUrl,
              helper: settings.urlHelper,
              error: settings.urlError,
              initial: settings.$.url,
            ),
            UrlOrKeyField(
              label: 'API Key',
              onChanged: settings.updateKey,
              helper: settings.keyHelper,
              error: settings.keyError,
              initial: settings.$.key,
            ),
            Obx(() => OutlinedButton(
              onPressed: settings.processing.value ? null : () async {
                await settings.verify();
                settings.processing.value = false;
              },
              child: Text('Verify key and save'),
            )),
          ],
        ),
      ),
    );
  }
}


class UrlOrKeyField extends HookWidget {
  final String label;
  final void Function(String) onChanged;
  final RxString helper, error;
  final String? initial;

  const UrlOrKeyField({
    super.key,
    required this.label,
    required this.onChanged,
    required this.helper,
    required this.error,
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
        helperText: helper.value == '' ? null : helper.value,
        errorText: error.value == '' ? null : error.value,
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