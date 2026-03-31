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

  final _urlHelper = ''.obs;
  final _keyHelper = ''.obs;
  final _urlError = ''.obs;
  final _keyError = ''.obs;
  final processing = false.obs;

  AppSettings get $ => _settings.value;

  String? get urlHelper => _getStringOrNull(_urlHelper.value);
  String? get keyHelper => _getStringOrNull(_keyHelper.value);
  String? get urlError => _getStringOrNull(_urlError.value);
  String? get keyError => _getStringOrNull(_keyError.value);

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
    _urlHelper.value = _urlError.value = '';
    _settings.value = _settings.value.copyWith(url: value);
  }
  void updateKey(String value) {
    _keyHelper.value = _keyError.value = '';
    _settings.value = _settings.value.copyWith(key: value);
  }

  String? _getStringOrNull(String value) {
    return value == '' ? null : value;
  }
}


extension Verify on SettingsController {
  Future<void> verify() async {
    processing.value = true;
    _urlHelper.value = _keyHelper.value = '';
    _urlError.value = _keyError.value = '';

    final uri = Uri.tryParse($.url);
    if (uri == null) {
      _urlError.value = 'Invalid URL';
      return;
    }

    final client = Client(accessKey: $.key, host: uri.host, port: uri.port);
    String response;
    try {
      response = await client.getVerifyAccessKey();
    } on HydrusUnknownHostException {
      _urlError.value = 'Host is unknown, probably wrong URL';
      return;
    } on HydrusNoServiceException {
      _urlError.value = 'No connection with Hydrus. Is your client running?';
      return;
    } on HydrusTimeoutException {
      _urlError.value = 'No response (timeout). Is this the correct host?';
      return;
    } on HydrusUnknownException {
      _urlError.value = 'Unknown error';
      return;
    } catch (e) {
      _urlError.value = 'Invalid URL';
      return;
    }

    final decoded = jsonDecode(response) as Map<String, dynamic>;
    if (decoded['error'] != null) {
      switch (decoded['status_code']) {
        case 400:
        case 401:
        case 403:
        case 419:
          _keyError.value = decoded['error'];
          return;
        default:
          _keyError.value = 'Unknown error';
          return;
      }
    }

    final box = GetStorage();
    box.write('url', $.url);
    box.write('key', $.key);
    Get.find<Repo>().updateClient();

    _urlError.value = _keyError.value = '';
    _urlHelper.value = _keyHelper.value = 'Saved';
  }
}