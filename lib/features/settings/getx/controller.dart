import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:hydit/core/services/executor.dart';
import 'package:hydit/core/services/snack.dart';
import 'package:string_validator/string_validator.dart';

import 'package:hydit/core/services/repo.dart';

import '../entity/model.dart';


class SettingsController extends GetxController {
  final _settings = AppSettings(
    url: '',
    key: '',
  ).obs;

  final _processing = false.obs;

  AppSettings get $ => _settings.value;
  bool get ready => !_processing.value;

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

  void verify() async {
    _processing.value = true;

    final result = await _verify();

    switch (result) {
      case Success(data: final _):
        Snack.success('Success', 'Successfully saved key and url');
      case Failure(title: final title, message: final message):
        Snack.error(title, message);
    }

    _processing.value = false;
  }

  Future<Result<String>> _verify() async {
    final uri = Uri.tryParse($.url);

    if (uri == null || !uri.host.isIP()) {
      return Failure(title: 'Input error', message: 'Invalid URL');
    }

    final Repo repo = Get.find<Repo>();
    final result = await repo.verify(uri, $.key);

    switch (result) {
      case Success(data: final _):
        save();
        repo.updateFromSettings();
      case _:
        break;
    }

    return result;
  }
}