import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:hydrus_flutter/core/data/api.dart';
import 'package:hydrus_flutter/core/data/repo.dart';
import 'package:hydrus_flutter/features/settings/data/model.dart';


class SettingsController extends GetxController {
  final _settings = AppSettings(
    url: '',
    key: '',
  ).obs;

  final urlHelper = ''.obs;
  final keyHelper = ''.obs;
  final urlError = ''.obs;
  final keyError = ''.obs;
  final processing = false.obs;

  AppSettings get $ => _settings.value;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void loadSettings() {
    final box = GetStorage();
    final url = box.read('url') ?? '';
    final key = box.read('key') ?? '';
    _settings.value = AppSettings(
      url: url,
      key: key,
    );
  }

  void updateUrl(String value) {
    urlHelper.value = urlError.value = '';
    _settings.value = _settings.value.copyWith(url: value);
  }
  void updateKey(String value) {
    keyHelper.value = keyError.value = '';
    _settings.value = _settings.value.copyWith(key: value);
  }
}


extension Verify on SettingsController {
  Future<void> verify() async {
    processing.value = true;
    urlHelper.value = keyHelper.value = '';
    urlError.value = keyError.value = '';

    final uri = Uri.tryParse($.url);
    if (uri == null) {
      urlError.value = 'Invalid URL';
      return;
    }

    final client = Client(accessKey: $.key, host: uri.host, port: uri.port);
    String response;
    try {
      response = await client.getVerifyAccessKey();
    } on HydrusUnknownHostException {
      urlError.value = 'Host is unknown, probably wrong URL';
      return;
    } on HydrusNoServiceException {
      urlError.value = 'No connection with Hydrus. Is your client running?';
      return;
    } on HydrusTimeoutException {
      urlError.value = 'No response (timeout). Is this the correct host?';
      return;
    } on HydrusUnknownException {
      urlError.value = 'Error';
      return;
    } catch (e) {
      urlError.value = 'Invalid URL';
      return;
    }

    final decoded = jsonDecode(response) as Map<String, dynamic>;
    if (decoded['error'] != null) {
      switch (decoded['status_code']) {
        case 400:
        case 401:
        case 403:
        case 419:
          keyError.value = decoded['error'];
          return;
        default:
          keyError.value = 'Unknown error';
          return;
      }
    }

    final box = GetStorage();
    box.write('url', $.url);
    box.write('key', $.key);
    Get.find<Repo>().updateClient();

    urlError.value = keyError.value = '';
    urlHelper.value = keyHelper.value = 'Saved';
  }
}