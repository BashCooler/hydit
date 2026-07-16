import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

import 'package:hydit/api/api.dart';
import 'package:hydit/utils/utils.dart';
import 'package:hydit/services/services.dart';


class SettingsController extends GetxController {
  final _settings = AppSettings(
    url: '',
    key: '',
  ).obs;

  SettingsController() {
    load();
  }

  AppSettings get $ => _settings.value;

  Repo repo = Get.find();

  Future<Result<void>> save() async {

    final uri = parseUrl($.url);

    if (uri is Failure) return uri;

    final api = HydrusApi.options(uri: uri.unwrapOrThrow(), key: $.key);

    final access = await api.getVerifyAccessKey().run();

    if (access is Failure) return access;

    final box = Hive.box('settings');
    box.put('url', $.url);
    box.put('key', $.key);

    Native
        .savePreferences($.url, $.key)
        .tapFailure(Snack.error);

    repo.api.load();

    return access;
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
}


class AppSettings {
  String url = '';
  String key = '';

  AppSettings({required this.url, required this.key});

  AppSettings copyWith({String? url, String? key}) {
    return AppSettings(
      url: url ?? this.url,
      key: key ?? this.key,
    );
  }
}
