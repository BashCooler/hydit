import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:settings_tiles/settings_tiles.dart';

import '../getx/controller.dart';
import '../widget/text_field.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final settings = Get.put(SettingsController());

  void snackBar(Icon icon, String title, String message) {
    Get.snackbar(
      title,
      message,
      dismissDirection: .horizontal,
      snackPosition: .BOTTOM,
      duration: const Duration(seconds: 10),
      animationDuration: const Duration(milliseconds: 450),
      forwardAnimationCurve: Curves.easeOutCubic,
      backgroundColor: Get
          .theme
          .colorScheme
          .surfaceContainerHigh,
      icon: icon,
    );
  }

  void verify() async {
    final result = await settings.verify();

    final Icon icon;
    final String title;
    final String message;

    switch (result.$1) {
      case Result.success:
        icon = Icon(Icons.check_circle_outline);
        title = 'Success';
        message = result.$2;
      case Result.error:
        icon = Icon(Icons.cancel_outlined);
        title = 'Error';
        message = result.$2;
    }

    snackBar(icon, title, message);
    settings.processing.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Column(
        spacing: 15,
        children: [
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
              icon: SettingTileIcon(Icons.save),
              title: Text('Verify and save'),
              onTap: verify,
            );
          }),
        ],
      ),
    );
  }
}
