import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:hydit/services/services.dart';

import '../getx/settings.dart';
import '../widget/text_field.dart';


class Settings extends HookWidget {
  const Settings({super.key});

  void showSaved(void result) {
    Snack.success('Success', 'Successfully saved key and url');
  }

  @override
  Widget build(BuildContext context) {

    final settings = useMemoized(() => SettingsController());

    final version = useFuture(Version.current());

    final saving = useState(false);

    final checking = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          spacing: 15,
          mainAxisSize: .min,
          children: [

            const Divider(color: Colors.transparent),

            SettingsTextField(
              label: 'Url',
              onChanged: settings.updateUrl,
              enabled: !saving.value,
              initial: settings.$.url,
            ),

            SettingsTextField(
              label: 'API Key',
              onChanged: settings.updateKey,
              enabled: !saving.value,
              initial: settings.$.key,
            ),

            ListTile(
              title: 'Verify and save'.n,
              leading: const Padding(
                padding: .all(8),
                child: Icon(Icons.save, size: 32),
              ),
              enabled: !saving.value,
              onTap: () => settings
                  .save()
                  .loading(saving)
                  .tapSuccess(showSaved)
                  .tapFailure(Snack.error),
            ),

            ListTile(
              enabled: !checking.value,
              leading: const Padding(
                padding: .all(8),
                child: FaIcon(FontAwesomeIcons.github, size: 32),
              ),
              title: version.hasData
                  ? 'v${version.data}'.n
                  : Skeletonizer(child: 'v.0.0.0'.n),
              subtitle: 'Check for updates'.n,
              onTap: () => checkForUpdates().loading(checking),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> checkForUpdates() async {

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
      update
          ? 'Update available'
          : 'Up to date',
      update
          ? 'Version ${release.tag}'
          : 'You have the latest version',
      TextButton.icon(
        onPressed: () => launchUrlString(release.url),
        label: 'Release'.n,
        icon: const FaIcon(FontAwesomeIcons.github),
      ),
    );
  }
}
