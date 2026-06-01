import 'dart:async';
import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:deep_pick/deep_pick.dart';

import 'package:hydit/core/data/api.dart';
import 'package:hydit/core/data/executor.dart';

import '../domain/entities.dart';
import 'mapper.dart';


class Repo {
  final HydrusApi api;
  final List<String> services = [];

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
    final response = await api.getFileMetadata(
      [file.id],
      includeServicesObject: false);
    Mapper.writeMetadata(response, file);
  }

  Future<String> serviceKeyOf(String name) async {
    final response = await api.getService(name: name);
    final decoded = jsonDecode(response);
    return decoded['service']['service_key'];
  }

  Future<void> addTags(List<int> ids, Set<Tag> tags) async {
    for (final service in tags.services) {
      final key = await serviceKeyOf(service);
      await api.postAddTags(
        ids, key, .addToLocalFileDomain, tags[service].rawList,
      );
    }
  }

  Future<void> removeTags(List<int> ids, Set<Tag> tags) async {
    for (final service in tags.services) {
      final key = await serviceKeyOf(service);
      await api.postAddTags(
        ids, key, .deleteFromLocalFileDomain, tags[service].rawList,
      );
    }
  }

  Future<Result<String>> updateServiceNames() async {
    final result = await Executor.run<String>(() => api.getServices());

    final dynamic json;
    switch (result) {
      case Failure(title: final _, message: final _):
        return result;
      case Success(data: final data):
        json = jsonDecode(data);
    }

    final List<dynamic> localTags = json['local_tags'];
    final local = localTags
        .map((e) => '${e['name']}')
        .toList();
    final ptr = pick(json, 'tag_repositories', 0, 'name')
        .asStringOrNull();
    services
      ..clear()
      ..add(pick(json, 'all_known_tags', 0, 'name').asStringOrThrow())
      ..addAll(local);
    if (ptr != null) services.add(ptr);

    return result;
  }
}
