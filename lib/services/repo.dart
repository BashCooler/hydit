import 'dart:async';

import 'package:deep_pick/deep_pick.dart';

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

  String buildUrl(int id, {bool thumbnail = false}) => ""
      "${api.url}/get_files/"
      "${thumbnail ? "thumbnail" : "file"}"
      "?file_id=$id"
      "&Hydrus-Client-API-Access-Key=${api.key}";

  Future<Result<void>> apply(Iterable<int> ids, List<TagDiff> changes) {
    final params = AddTagsParams(ids: ids, changes: changes);
    return api.postAddTags(params).run();
  }

  Future<Result<void>> update(List<HydrusFile> files) async {

    for (final chunk in files.chunked(20)) {

      final result = await api
          .getFileMetadata(chunk.map((f) => f.id))
          .run();

      if (result is Failure) return result;

      final tags = result
          .unwrapOrThrow()
          .pick('metadata')
          .asListOrThrow(Tags.fromPick);

      for (var i = 0; i < chunk.length; i++) {
        chunk[i].tags.value = tags[i];
      }
    }

    return Success(null);
  }

  Future<Result<void>> download(int id) async {

    final bytes = await api.getFile(id).run();

    if (bytes is Failure) return bytes;

    final data = await api
        .getFileMetadata([id], onlyReturnBasicInformation: true)
        .run();

    if (data is Failure) return data;

    final meta = data
        .unwrapOrThrow()
        .pick('metadata', 0)
        .let(FileMetadata.fromPick);

    return Native
        .saveFile(bytes.unwrapOrThrow(), meta.fileName, meta.mime);
  }
}
