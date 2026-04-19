import 'dart:convert';
import 'package:hive_ce/hive.dart';
import 'package:deep_pick/deep_pick.dart';

import 'package:hydrus_flutter/core/data/api.dart';
import 'package:hydrus_flutter/utils/dictionaries.dart';

import 'mapper.dart';
import '../domain/entities.dart';


class Repo {
  final Client api;
  final List<String> services = [];

  Repo(this.api);

  void updateClient() {
    final box = Hive.box('settings');
    final key = box.get('key') ?? '';
    final url = box.get('url') ?? '';
    final uri = Uri.parse(url);
    api.updateClient(key: key, uri: uri);
  }

  Future<void> setMetadataFor(HydrusImage image) async {
    final response = await api.getFileMetadata(
      [image.id],
      includeServicesObject: false);
    await Mapper.writeMetadata(response, image);
  }

  String buildUrl(int id, {bool thumbnail = false}) => ""
      "http://${api.host}:${api.port}/get_files/"
      "${thumbnail ? "thumbnail" : "file"}"
      "?file_id=$id"
      "&Hydrus-Client-API-Access-Key=${api.accessKey}";

  Future<String> getServiceByName(String name) async {
    final response = await api.getService(name: name);
    final decoded = jsonDecode(response);
    return decoded['service']['service_key'];
  }

  Future<int> addTags(int id, String service, List<String> tags) async {
    return await api.postAddTags(id, service, Action.addToLocalFileDomain, tags);
  }

  Future<int> removeTags(int id, String service, List<String> tags) async {
    return await api.postAddTags(id, service, Action.deleteFromLocalFileDomain, tags);
  }

  Future<void> updateServiceNames() async {
    final response = await api.getServices();
    final json = jsonDecode(response);
    final localTags = json['local_tags'] as List<dynamic>;
    final local = localTags.map((e) => '${e['name']}').toList();
    final ptr = pick(json, 'tag_repositories', 0, 'name').asStringOrNull();
    services
      ..clear()
      ..add(pick(json, 'all_known_tags', 0, 'name').asStringOrThrow())
      ..addAll(local);
    if (ptr != null) services.add(ptr);
  }
}
