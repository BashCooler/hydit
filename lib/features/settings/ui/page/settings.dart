import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:settings_tiles/settings_tiles.dart';

import 'package:hydrus_flutter/core/ui/snack_bar.dart';

import '../getx/controller.dart';
import '../widget/text_field.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final settings = Get.put(SettingsController());

  void verify() async {
    final result = await settings.verify();
    showErrorOrSuccess(result);
    settings.processing.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        elevation: 2,
      ),
      body: Column(
        spacing: 15,
        children: [
          Divider(color: Colors.transparent),
          SettingsTextField(
            label: 'Url',
            onChanged: settings.updateUrl,
            initial: settings.$.url,
          ),
          SettingsTextField(
            label: 'API Key',
            onChanged: settings.updateKey,
            initial: settings.$.key,
          ),
          Obx(() {
            return SettingActionTile(
              enabled: !settings.processing.value,
              icon: const SettingTileIcon(Icons.save),
              title: const Text('Verify and save'),
              onTap: verify,
            );
          }),
        ],
      ),
    );
  }
}
