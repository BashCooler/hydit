import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:hydit/core/data/executor.dart';
import 'package:string_validator/string_validator.dart';

import 'package:hydit/core/data/api.dart';
import 'package:hydit/features/settings/data/model.dart';


class SettingsController extends GetxController {
  final _settings = AppSettings(
    url: '',
    key: '',
  ).obs;

  final processing = false.obs;

  AppSettings get $ => _settings.value;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void loadSettings() {
    final box = Hive.box('settings');
    final url = box.get('url') ?? '';
    final key = box.get('key') ?? '';
    _settings.value = AppSettings(
      url: url,
      key: key,
    );
  }

  void updateUrl(String value) {
    _settings.value = _settings.value.copyWith(url: value);
  }
  void updateKey(String value) {
    _settings.value = _settings.value.copyWith(key: value);
  }

  Future<Result> verify() async {
    processing.value = true;

    final uri = Uri.tryParse($.url);
    if (uri == null) return Failure('Input error', 'Invalid URL');
    if (!uri.host.isIP()) return Failure('Input error', 'Invalid IP');

    final client = HydrusApi(uri: uri, key: $.key);

    return Executor.run(() {
      return client.getVerifyAccessKey();
    });
  }
}