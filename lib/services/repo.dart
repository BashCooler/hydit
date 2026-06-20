import 'dart:async';

import 'package:hive_ce/hive.dart';

import 'package:hydit/api/api.dart';
import 'package:hydit/api/models.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/services/snack.dart';
import 'package:hydit/utils/dictionaries.dart';

import 'mapper.dart';
import 'executor.dart';


class Repo {
  final HydrusApi api;
  final Map<String, String> services = {};

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

  // MARK: ADD & DELETE TAGS

  Future<Result<void>> addTags(Iterable<int> ids, Set<Tag> additions) {
    return _addOrRemove(ids, additions, .addToLocalFileDomain);
  }

  Future<Result<void>> removeTags(Iterable<int> ids, Set<Tag> deletions) {
    return _addOrRemove(ids, deletions, .deleteFromLocalFileDomain);
  }

  Future<Result<void>> _addOrRemove(Iterable<int> ids, Set<Tag> tags,
      AddTagsAction action) async {

    final operations = tags.services.map((name) {
      final params = AddTagsParamsBuilder()
        ..ids = ids
        ..action = action
        ..key = services[name]!
        ..tags = tags.of(name);

      return api.postAddTags(params.build()).run();
    });

    return await ExecutorBatch().queueAll(operations).run();
  }

  Future<Result<String>> updateServices() async {
    return await api
        .getServices()
        .run()
        .tapSuccess((s) => services.assignAll(s.mapServices()))
        .tapFailure(Snack.error);
  }
}
