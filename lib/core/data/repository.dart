import 'package:get/get.dart';
import 'package:hydrus_flutter/core/data/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mapper.dart';
import '../domain/entities.dart';


class Repo {
  final Client api;

  Repo(this.api);

  void updateClient() {
    final prefs = Get.find<SharedPreferences>();
    final key = prefs.getString('Hydrus API key') ?? '';
    final uri = Uri.parse(prefs.getString('URL') ?? '');
    api.updateClient(key: key, uri: uri);
  }

  Future<void> setMetadataFor(HydrusImage image) async {
    final response = await api.getFileMetadata(
      [image.id],
      includeServicesObject: false);
    Mapper.writeMetadata(response, image);
  }

  String buildUrl(int id, {bool thumbnail = false}) => ""
      "http://${api.host}:${api.port}/get_files/"
      "${thumbnail ? "thumbnail" : "file"}"
      "?file_id=$id"
      "&Hydrus-Client-API-Access-Key=${api.accessKey}";
}
