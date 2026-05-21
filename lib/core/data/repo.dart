import 'dart:async';
import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:deep_pick/deep_pick.dart';

import 'package:hydit/core/data/api.dart';
import 'package:hydit/utils/dictionaries.dart';

import 'mapper.dart';
import '../domain/entities.dart';

enum Result { success, error }


class Repo {
  final Client api;
  final List<String> services = [];

  Repo() : api = Client() {
    updateClient();
  }

  void updateClient() {
    final box = Hive.box('settings');
    final key = box.get('key') ?? '';
    final url = box.get('url') ?? '';
    final uri = Uri.parse(url);
    api.updateClient(key: key, uri: uri);
  }

  Future<void> setMetadataFor(HydrusFile? image) async {
    if (image == null) return;
    final response = await api.getFileMetadata(
      [image.id],
      includeServicesObject: false);
    await Mapper.writeMetadata(response, image);
    image.ready.value = true;
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

  Future<int> addTags(List<int> ids, String service, List<String> tags) async {
    return await api.postAddTags(ids, service, Action.addToLocalFileDomain, tags);
  }

  Future<int> removeTags(List<int> ids, String service, List<String> tags) async {
    return await api.postAddTags(ids, service, Action.deleteFromLocalFileDomain, tags);
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

  Future<(Result, String)> verify([Client? client]) async {
    String response;
    try {
      final c = client ?? api;
      response = await c.getVerifyAccessKey();
    } on HydrusUnknownHostException {
      final message = 'Host is unknown, probably wrong URL';
      return (Result.error, message);
    } on HydrusNoServiceException {
      final message = 'No connection with Hydrus';
      return (Result.error, message);
    } on HydrusTimeoutException {
      final message = 'No response (timeout)';
      return (Result.error, message);
    } on TimeoutException {
      final message = 'No response (timeout)';
      return (Result.error, message);
    } on HydrusUnknownException {
      final message = 'Unknown error';
      return (Result.error, message);
    } catch (e) {
      final message = e.toString();
      return (Result.error, message);
    }

    final decoded = jsonDecode(response) as Map<String, dynamic>;
    if (decoded['error'] != null) {
      return decoded['error'];
    }

    return (Result.success, 'Success');
  }
}
