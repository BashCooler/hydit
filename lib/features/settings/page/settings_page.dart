import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:hydit/services/snack.dart';
import 'package:hydit/services/version.dart';
import 'package:hydit/services/executor.dart';

import '../getx/settings.dart';
import '../widget/text_field.dart';


class Settings extends HookWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {

    final settings = useMemoized(() => SettingsController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          spacing: 15,
          mainAxisSize: .min,
          children: [

            const Divider(color: Colors.transparent),

            Obx(() {
              return SettingsTextField(
                label: 'Url',
                onChanged: settings.updateUrl,
                enabled: settings.ready,
                initial: settings.$.url,
              );
            }),

            Obx(() {
              return SettingsTextField(
                label: 'API Key',
                onChanged: settings.updateKey,
                enabled: settings.ready,
                initial: settings.$.key,
              );
            }),

            Obx(() {
              return ListTile(
                title: 'Verify and save'.n,
                leading: Padding(
                  padding: const .all(8),
                  child: const Icon(Icons.save, size: 32),
                ),
                enabled: settings.ready,
                onTap: settings.verify,
              );
            }),

            ListTile(
              leading: const Padding(
                padding: .all(8),
                child: FaIcon(FontAwesomeIcons.github, size: 32),
              ),
              title: FutureBuilder(
                future: Version.current(),
                builder: (context, snapshot) {
                  switch (snapshot.hasData) {
                    case true:
                      return 'v${snapshot.data!}'.n;
                    case false:
                      return Skeletonizer(child: 'v0.0.0'.n);
                  }
                },
              ),
              subtitle: 'Check for updates'.n,
              onTap: () async {
                final release = await Version
                    .checkForUpdates()
                    .tapFailure(Snack.error)
                    .unwrap();

                if (release == null) return;

                final update = release.update;

                Snack.snackBar(
                  update
                      ? const Icon(Icons.system_update_alt)
                      : const Icon(Icons.check),
                  update ? 'Update available' : 'Up to date',
                  'You have the latest version',
                  TextButton.icon(
                    onPressed: () => launchUrlString(release.url),
                    label: 'Release'.n,
                    icon: const FaIcon(FontAwesomeIcons.github),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
