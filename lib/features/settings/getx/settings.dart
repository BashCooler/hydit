import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

import 'package:hydit/api/api.dart';
import 'package:hydit/utils/utils.dart';
import 'package:hydit/services/services.dart';


class SettingsController {
  String url = '127.0.0.1:45869';
  String key = '';

  SettingsController() {
    load();
  }

  Repo repo = Get.find();

  void load() {
    final box = Hive.box('settings');

    url = box.get('url') ?? '';
    key = box.get('key') ?? '';
  }

  Future<Result<void>> save() async {
    final uri = parseUrl(url);

    if (uri is Failure) return uri;

    final api = HydrusApi.options(uri: uri.unwrapOrThrow(), key: key);

    final access = await api.getVerifyAccessKey().run();

    if (access is Failure) return access;

    final box = Hive.box('settings');
    box.put('url', url);
    box.put('key', key);

    Native
        .savePreferences(url, key)
        .tapFailure(Snack.error);

    repo.api.load();

    return access;
  }
}
