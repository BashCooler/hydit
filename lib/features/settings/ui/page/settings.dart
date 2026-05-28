import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/core/data/executor.dart';
import 'package:niku/namespace.dart' as n;
import 'package:skeletonizer/skeletonizer.dart';
import 'package:settings_tiles/settings_tiles.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:hydit/core/data/version.dart';
import 'package:hydit/core/ui/snack_bar.dart';

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
    settings.processing.value = true;

    final result = await settings.verify();

    switch (result) {
      case Success(data: final _):
        snackBar(
          const Icon(Icons.check),
          'Success',
          'Successfully saved key and url',
        );
      case Failure(title: final title, message: final message):
        snackBar(const Icon(Icons.clear), title, message);
    }

    settings.processing.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
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
            SettingActionTile(
              icon: const Padding(
                padding: .all(8),
                child: FaIcon(FontAwesomeIcons.github, size: 32),
              ),
              title: FutureBuilder(
                future: version(),
                builder: (context, snapshot) {
                  switch (snapshot.hasData) {
                    case true:
                      return 'v${snapshot.data!}'.n;
                    case false:
                      return Skeletonizer(child: 'v0.0.0'.n);
                  }
                },
              ),
              description: n.Row([
                'Latest version: '.n,
                FutureBuilder(
                  future: getLatestVersion(),
                  builder: (context, snapshot) {
                    switch (snapshot.hasData) {
                      case true:
                        return 'v${snapshot.data!}'.n;
                      case false:
                        return Skeletonizer(child: 'v0.0.0'.n);
                    }
                  },
                )
              ]),
              onTap: () async {
                try {
                  await launchUrl(
                    Uri.parse(downloadUrl),
                    customTabsOptions: CustomTabsOptions(shareState: .off),
                  );
                } catch (e) {
                  return;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
