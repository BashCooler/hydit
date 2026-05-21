import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:settings_tiles/settings_tiles.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:hydit/core/data/version.dart';
import 'package:hydit/core/ui/snack_bar.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
              icon: Padding(
                padding: .all(8),
                child: const FaIcon(FontAwesomeIcons.github, size: 32),
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
