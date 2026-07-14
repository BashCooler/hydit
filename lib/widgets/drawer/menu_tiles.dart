import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/features/search/getx/query.dart';
import 'package:hydit/features/settings/bindings.dart';

import '../../features/gallery/getx/selection.dart';


class InboxTile extends StatelessWidget {
  final String tag;

  const InboxTile({super.key, required this.tag});

  QueryController get query => Get.find(tag: tag);
  SelectionController get selection => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.mail_outline),
      title: const Text("Inbox"),
      onTap: () {
        selection.clear();
        query
          ..clear()
          ..add('system:inbox')
          ..search();
        Get.back();
      },
    );
  }
}


class SettingsTile extends StatelessWidget {
  final String tag;

  const SettingsTile({super.key, required this.tag});

  SelectionController get selection => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.settings),
      title: const Text('Settings'),
      onTap: () {
        selection.clear();
        SettingsPage().push();
      },
    );
  }
}

