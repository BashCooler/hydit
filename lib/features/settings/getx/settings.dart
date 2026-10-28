import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydit/api/api.dart';
import 'package:hydit/utils/url.dart';
import 'package:hydit/services/services.dart';


enum Protocol {
  http('http://'),
  https('https://');

  final String scheme;

  const Protocol(this.scheme);
}


class SettingsController() extends GetxController {
  Protocol protocol = Protocol.http;

  final urlController = TextEditingController();

  late final keyController = TextEditingController(text: key);

  String host = '127.0.0.1:45869';
  String key = '';

  this {
    load();
  }

  Repo get repo => Get.find();

  Storage get box => Get.find<Storage>();

  @override
  void onClose() {
    urlController.dispose();
    keyController.dispose();
    super.onClose();
  }

  String buildUrl() => '${protocol.scheme}$host';

  void load() {
    setUrl(box.get('url') ?? '');
    key = box.get('key') ?? '';
  }

  Future<Result<void>> save() async {
    final url = buildUrl();

    final access = await parseUrl(url).flatMap(
      (uri) => HydrusApi(uri: uri, key: key).getVerifyAccessKey().run(),
    );

    if (access is Failure) return access;

    box.put('url', url);
    box.put('key', key);

    repo.api.load();

    return Native.savePreferences(url, key).run();
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
