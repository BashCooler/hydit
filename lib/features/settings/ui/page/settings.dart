import 'dart:developer';

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
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          UrlField(),
          Divider(color: Colors.transparent),
          TextField(),
          Divider(color: Colors.transparent),
          OutlinedButton(
            onPressed: settings.processing ? null : () async {
              await settings.verify();
              settings.processing = false;
            },
            child: Text('Verify key and save'),
          ),
          OutlinedButton(
            onPressed: () {
              log(settings.$.url.toString());
              log(settings.$.key.toString());
            },
            child: Text('Check'),
          )
        ],
      ),
    );
  }
}


class UrlField extends StatelessWidget {
  const UrlField({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settings = Get.find();
    return TextFormField(
      initialValue: settings.$.url,
      onChanged: settings.updateUrl,
    );
  }
}


class KeyField extends StatelessWidget {
  const KeyField({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settings = Get.find();
    return TextFormField(
      initialValue: settings.$.key,
      onChanged: settings.updateKey,
    );
  }
}

