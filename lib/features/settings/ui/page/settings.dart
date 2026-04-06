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
            UrlField(),
            KeyField(),
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


class UrlField extends StatelessWidget {
  const UrlField({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settings = Get.find();
    return Obx(() => TextFormField(
      initialValue: settings.$.url,
      enabled: !settings.processing.value,
      onChanged: settings.updateUrl,
      onTapOutside: (_) => Get.focusScope?.unfocus(),
      decoration: InputDecoration(
        labelText: 'URL',
        helperText: settings.urlHelper,
        errorText: settings.urlError,
        floatingLabelBehavior: .always,
      ),
    ));
  }
}


class KeyField extends StatelessWidget {
  const KeyField({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settings = Get.find();
    return Obx(() => TextFormField(
      initialValue: settings.$.key,
      enabled: !settings.processing.value,
      onChanged: settings.updateKey,
      onTapOutside: (_) => Get.focusScope?.unfocus(),
      decoration: InputDecoration(
        labelText: 'API key',
        helperText: settings.keyHelper,
        errorText: settings.keyError,
        floatingLabelBehavior: .always,
      ),
    ));
  }
}

