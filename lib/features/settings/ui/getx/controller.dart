import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:hydit/core/data/executor.dart';
import 'package:hydit/core/data/repo.dart';
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
    load();
  }

  void save() {
    final box = Hive.box('settings');
    box.put('url', $.url);
    box.put('key', $.key);
  }

  void load() {
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

  Future<Result<String>> verify() async {
    final uri = Uri.tryParse($.url);

    if (uri == null || !uri.host.isIP()) {
      return Failure(title: 'Input error', message: 'Invalid URL');
    }

    final client = HydrusApi(uri: uri, key: $.key);

    final result = await Executor
        .run<String>(() => client.getVerifyAccessKey());

    switch (result) {
      case Success(data: final _):
        save();
        Get.find<Repo>().updateClient();
      case _:
        break;
    }

    return result;
  }
}