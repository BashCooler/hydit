import 'dart:async';

import 'package:get/get.dart';
import 'package:hydit/entities/cache.dart';

import 'package:hydit/api/api.dart';
import 'package:hydit/api/params.dart';
import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/entities/tags.dart';
import 'package:hydit/entities/service.dart';
import 'package:hydit/entities/metadata.dart';
import 'package:hydit/services/services.dart';


class Repo {
  final HydrusApi api;

  Repo() : api = HydrusApi.load();

  FileCache get cache => Get.find();

  String buildUrl(int id, {bool thumbnail = false}) => ""
      "${api.url}/get_files/"
      "${thumbnail ? "thumbnail" : "file"}"
      "?file_id=$id"
      "&Hydrus-Client-API-Access-Key=${api.key}";

  String render(int id) => ""
      "${api.url}/get_files/render"
      "?file_id=$id"
      "&Hydrus-Client-API-Access-Key=${api.key}";

  Future<Result<void>> apply(
    Iterable<int> ids,
    List<TagDiff> changes,
  ) {
    final params = AddTagsParams(ids: ids, changes: changes);
    return api.postAddTags(params).run();
  }

  Future<Result<void>> update(List<HydrusFile> files) async {

    for (final chunk in files.chunked(20)) {

      final result = await api
          .getFileMetadata(chunk.map((f) => f.id))
          .run()
          .pick('metadata')
          .asListOrThrow(Tags.fromPick);

      if (result is Failure) return result;

      final tags = result.unwrapOrThrow();

      for (var i = 0; i < chunk.length; i++) {
        chunk[i].tags.value = tags[i];
      }
    }

    return Success(null);
  }

  Future<Result<void>> download(int id) async {

    final bytes = await api.getFile(id).run();

    if (bytes is Failure) return bytes;

    final metadata = await api
        .getFileMetadata([id], onlyReturnBasicInformation: true)
        .run()
        .pick('metadata', 0)
        .map(FileMetadata.fromPick);

    if (metadata is Failure) return metadata;

    final meta = metadata.unwrapOrThrow();

    return Native
        .saveFile(bytes.unwrapOrThrow(), meta.fileName, meta.mime);
  }
}
