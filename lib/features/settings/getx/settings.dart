import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/api/api.dart';
import 'package:hydit/utils/utils.dart';
import 'package:hydit/services/services.dart';


enum Protocol {
  http('http://'),
  https('https://');

  final String scheme;

  const Protocol(this.scheme);
}


class SettingsController {
  Protocol protocol = Protocol.http;

  final urlController = TextEditingController();

  String host = '127.0.0.1:45869';
  String key = '';

  SettingsController() {
    load();
  }

  Repo repo = Get.find();

  Storage get box => Get.find<Storage>();

  String buildUrl() => '${protocol.scheme}$host';

  void load() {
    setUrl(box.get('url') ?? '');
    key = box.get('key') ?? '';
  }

  Future<Result<void>> save() async {
    final url = buildUrl();

    final access = await parseUrl(url)
        .map((uri) => HydrusApi(uri: uri, key: key))
        .flatMap((api) => api.getVerifyAccessKey().run());

    if (access is Failure) return access;

    box.put('url', url);
    box.put('key', key);

    Native
        .savePreferences(url, key)
        .tapFailure(Snack.error);

    repo.api.load();

    return access;
  }

  void setUrl(String url) {
    final uri = Uri.tryParse(url);

    host = url
        .replaceFirst(RegExp(r'^https?:/?/?'), '');

    switch (uri?.scheme) {
      case 'http':
        protocol = .http;
        urlController.text = host;
      case 'https':
        protocol = .https;
        urlController.text = host;
    }
  }
}
