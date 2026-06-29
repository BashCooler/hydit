import 'dart:async';

import 'package:hive_ce/hive.dart';

import 'package:hydit/api/api.dart';
import 'package:hydit/api/params.dart';
import 'package:hydit/entities/service.dart';

import 'executor.dart';


class Repo {
  final HydrusApi api;

  Repo() : api = HydrusApi() {
    updateFromSettings();
  }

  void updateFromSettings() {
    final box = Hive.box('settings');
    final key = box.get('key') ?? '';
    final url = box.get('url') ?? '';
    api.update(Uri.parse(url), key);
  }

  String buildUrl(int id, {bool thumbnail = false}) => ""
      "${api.url}/get_files/"
      "${thumbnail ? "thumbnail" : "file"}"
      "?file_id=$id"
      "&Hydrus-Client-API-Access-Key=${api.key}";

  Future<Result<void>> apply(Iterable<int> ids, List<TagDiff> changes) {
    final params = AddTagsParams(ids: ids, changes: changes);
    return api.postAddTags(params).run();
  }
}
