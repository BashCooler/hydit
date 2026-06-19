import 'dart:async';
import 'dart:convert';

import 'package:hive_ce/hive.dart';

import 'package:hydit/api/api.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/reactive/file.dart';
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

  Future<void> setMetadataFor(HydrusFile? file) async {
    if (file == null) return;

    final data = await api
        .getFileMetadata([file.id])
        .run()
        .unwrap();

    if (data != null) {
      Mapper.writeMetadata(data, file);
    }
  }

  Future<Result<void>> addTags(List<int> ids, Set<Tag> tags) {
    return _addOrRemove(ids, tags, .addToLocalFileDomain);
  }

  Future<Result<void>> removeTags(List<int> ids, Set<Tag> tags) {
    return _addOrRemove(ids, tags, .deleteFromLocalFileDomain);
  }

  Future<Result<void>> _addOrRemove(List<int> ids, Set<Tag> tags,
      Action action) {

    return Executor.run(() async {
      for (final name in tags.services) {
        final key = services[name];
        await api.postAddTags(ids, key!, action, tags[name].rawList);
      }
    });
  }

  Future<void> updateServices() async {
    final response = await api
        .getServices()
        .run()
        .onFailure(Snack.error)
        .unwrap();

    if (response == null) return;

    services.assignAll(Mapper.mapServices(response));
  }
}
