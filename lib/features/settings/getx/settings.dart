import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:hydit/api/api.dart';
import 'package:string_validator/string_validator.dart';

import 'package:hydit/services/repo.dart';
import 'package:hydit/services/snack.dart';
import 'package:hydit/services/native.dart';
import 'package:hydit/services/executor.dart';


class SettingsController extends GetxController {
  final _settings = AppSettings(
    url: '',
    key: '',
  ).obs;

  final _processing = false.obs;

  SettingsController() {
    load();
  }

  AppSettings get $ => _settings.value;
  bool get ready => !_processing.value;

  Repo get repo => Get.find();

  void save() {
    final box = Hive.box('settings');
    box.put('url', $.url);
    box.put('key', $.key);

    Native
        .savePreferences($.url, $.key)
        .tapFailure(Snack.error);
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

  Future<void> verify() async {
    final uri = Uri.tryParse($.url);

    if (uri == null || !uri.host.isIP()) {
      Snack.error('Input error', 'Invalid URL');
      return;
    }

    await HydrusApi(uri: uri, key: $.key)
        .getVerifyAccessKey()
        .run()
        .loading(_processing)
        .tapSuccess(_onSuccess)
        .tapFailure(Snack.error);
  }

  void _onSuccess(String data) {
    save();
    repo.updateFromSettings();
    Snack.success('Success', 'Successfully saved key and url');
  }
}


/// Object representing settings structure.
///
/// You can make this object observable to
/// perform reactive updates on parameter
/// change.
class AppSettings {
  String url = '';
  String key = '';

  AppSettings({required this.url, required this.key});

  /// Changing [AppSettings] value with this method
  /// ensures UI updates are working fine.
  ///
  /// Returns new [AppSettings] object with applied
  /// changes.
  AppSettings copyWith({String? url, String? key}) {
    return AppSettings(
      url: url ?? this.url,
      key: key ?? this.key,
    );
  }
}
