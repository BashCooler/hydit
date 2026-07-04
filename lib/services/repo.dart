import 'dart:async';
import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:hive_ce/hive.dart';
import 'package:deep_pick/deep_pick.dart';

import 'package:hydit/api/api.dart';
import 'package:hydit/api/params.dart';
import 'package:hydit/entities/service.dart';
import 'package:hydit/entities/tags.dart';
import 'package:hydit/reactive/file.dart';

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

  Future<Result<void>> update(List<HydrusFile> files) async {
    for (final chunk in files.chunked(20)) {

      final result = await api
          .getFileMetadata(chunk.map((f) => f.id))
          .run();

      if (result is Failure) return result;

      final json = result.unwrapOrThrow();

      final tags = pick(jsonDecode(json), 'metadata')
          .asListOrThrow((e) => e.asMapOrThrow<String, dynamic>())
          .map(Tags.fromMap)
          .toList();

      for (var i = 0; i < files.length; i++) {
        files[i].tags.value = tags[i];
      }
    }

    return Success(null);
  }
}
