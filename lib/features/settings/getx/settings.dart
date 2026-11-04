import 'package:get/get.dart';
import 'package:flutter/material.dart';

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

  Api get api => Get.find();

  Storage get box => Get.find<Storage>();

  @override
  void onClose() {
    urlController.dispose();
    keyController.dispose();
    super.onClose();
  }

  String get url => '${protocol.scheme}$host';

  void load() {
    setUrl(box.get('url') ?? '');
    key = box.get('key') ?? '';
  }

  Future<Result<String>> save() async {
    return runCatching(
      () => validateUrl(url),
    ).mapCatching(
      (url) async {
        final access = await Api(url: url, key: key)
            .getVerifyAccessKey();

        box.put('url', url);
        box.put('key', key);

        await Native.savePreferences(url, key);

        api.update(url, key);

        return access;
      },
    ).map(
      (r) => switch (r) {
        {'human_description': final String msg} => msg,
        _ => 'Successfully saved key and url',
      },
    );
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
