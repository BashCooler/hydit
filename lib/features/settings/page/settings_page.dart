import 'package:flutter/material.dart';
import 'package:hydit/utils/utils.dart';
import 'package:niku/namespace.dart' as n;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:hydit/services/services.dart';
import 'package:hydit/widgets/common/swipeable.dart';

import '../getx/settings.dart';
import '../widget/text_field.dart';


class Settings extends HookWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {

    final settings = useMemoized(() => SettingsController());

    final saving = useState(false);

    return SwipeableScaffold(
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
              onChanged: settings.setUrl,
              enabled: !saving.value,
              controller: settings.urlController,
            ),

            ProtocolSelector(
              initial: settings.protocol,
              onChange: (p) => settings.protocol = p,
              enabled: saving.value.not(),
            ),

            SettingsTextField(
              label: 'API Key',
              onChanged: (key) => settings.key = key,
              enabled: !saving.value,
              controller: settings.keyController,
            ),

            ListTile(
              title: 'Verify and save'.n,
              leading: const Padding(
                padding: .all(8),
                child: Icon(Icons.save, size: 32),
              ),
              enabled: !saving.value,
              onTap: () => settings.save().loading(saving).match(
                ok: (msg) => Snack.success('Success', msg),
                err: Snack.error,
              ),
            ),

            const VersionTile(),
          ],
        ),
      ),
    );
  }
}


class const ProtocolSelector({
  super.key,
  required final Protocol initial,
  required final void Function(Protocol p) onChange,
  final bool enabled = true,
}) extends HookWidget {
  //
  @override
  Widget build(BuildContext context) {
    //
    final protocol = useState(initial);

    return SegmentedButton<Protocol>(
      segments: const [
        ButtonSegment(
          value: .http,
          icon: Icon(Icons.http),
          label: Text('HTTP'),
        ),
        ButtonSegment(
          value: .https,
          icon: Icon(Icons.security),
          label: Text('HTTPS'),
        ),
      ],
      selected: {
        protocol.value,
      },
      onSelectionChanged: enabled
          ? (selected) => protocol.value = selected.first.also(onChange)
          : null,
    );
  }
}


class VersionTile extends HookWidget {
  const VersionTile({super.key});

  static Future<void> checkForUpdates() async {

    final release = await UpdateService.latestRelease()
        .tapFailure(Snack.error)
        .getOrNull();

    if (release == null) return;

    Snack.snackBar(
      release.isUpdate
          ? const Icon(Icons.system_update_alt)
          : const Icon(Icons.check),
      release.isUpdate
          ? 'Update available'
          : 'Up to date',
      release.isUpdate
          ? 'Version ${release.version}'
          : 'You have the latest version',
      TextButton.icon(
        onPressed: () => release.httpUrl?.let(launchUrlString),
        label: const Text('Release'),
        icon: const FaIcon(FontAwesomeIcons.github),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final future = useMemoized(UpdateService.current);

    final version = useFuture(future, initialData: 'v0.0.0');

    final checking = useState(false);

    return ListTile(
      enabled: !checking.value,
      leading: const Padding(
        padding: .all(8),
        child: FaIcon(FontAwesomeIcons.github, size: 32),
      ),
      title: 'v${version.data}'.n,
      subtitle: 'Check for updates'.n,
      onTap: () => checkForUpdates().loading(checking),
    );
  }
}
