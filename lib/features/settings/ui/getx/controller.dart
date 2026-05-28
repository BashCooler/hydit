import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:string_validator/string_validator.dart';

import 'package:hydit/core/data/api.dart';
import 'package:hydit/core/data/repo.dart';
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
}


extension Verify on SettingsController
{
  Future<(Result, String)> verify() async {
    processing.value = true;

    final uri = Uri.tryParse($.url);
    if (uri == null) return (Result.error, 'Invalid URL');
    if (!uri.host.isIP()) return (Result.error, 'Invalid IP');

    final client = HydrusApi(uri: uri, key: $.key);

    final Repo repo = Get.find();
    final result = await repo.verify(client);
    if (result.$1 == .error) return result;

    final box = Hive.box('settings');
    box.put('url', $.url);
    box.put('key', $.key);
    Get.find<Repo>().updateClient();

    return (Result.success, 'URL and key successfully saved');
  }
}