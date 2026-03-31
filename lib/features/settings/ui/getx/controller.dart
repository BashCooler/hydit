import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:hydrus_flutter/core/data/api.dart';
import 'package:hydrus_flutter/core/data/repo.dart';
import 'package:hydrus_flutter/features/settings/data/model.dart';


class SettingsController extends GetxController {
  static const defaultUrl = 'http://127.0.0.1:45869/';

  final _settings = AppSettings(
    url: defaultUrl,
    key: '',
  ).obs;

  final _urlHint = ''.obs;
  final _keyHint = ''.obs;
  final _urlError = ''.obs;
  final _keyError = ''.obs;
  final _processing = false.obs;

  AppSettings get $ => _settings.value;
  bool get processing => _processing.value;

  String? get urlHint => _getStringOrNull(_urlHint.value);
  String? get keyHint => _getStringOrNull(_keyHint.value);
  String? get urlError => _getStringOrNull(_urlError.value);
  String? get keyError => _getStringOrNull(_keyError.value);

  set processing(bool state) => _processing.value;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void loadSettings() {
    final box = GetStorage();
    final url = box.read('URL') ?? defaultUrl;
    final key = box.read('Hydrus API key') ?? '';
    _settings.value = AppSettings(
      url: url,
      key: key,
    );
  }

  String? _getStringOrNull(String value) {
    return value == '' ? null : value;
  }

  void updateUrl(String value) => _settings.value = _settings.value.copyWith(url: value);
  void updateKey(String value) => _settings.value = _settings.value.copyWith(key: value);

  Future<void> verify() async {
    _processing.value = true;
    _urlHint.value = _keyHint.value = '';
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
    _urlHint.value = _keyHint.value = 'Saved';
  }
}