import 'package:flutter/material.dart';


class const InboxTile({
  super.key,
  final void Function()? onTap,
}) extends StatelessWidget {
  //
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.mail_outline),
      title: const Text("Inbox"),
      onTap: onTap,
    );
  }
}

class const SettingsTile ({
  super.key,
  required final void Function()? onTap,
}) extends StatelessWidget {
  //
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.settings),
      title: const Text('Settings'),
      onTap: onTap,
    );
  }
}

