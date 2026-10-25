import 'dart:async';

import 'package:get/get.dart';

import 'package:hydit/api/api.dart';
import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/reactive/cache.dart';
import 'package:hydit/entities/tags.dart';
import 'package:hydit/services/services.dart';


class Repo() {
  final HydrusApi api;

  this : api = HydrusApi.load();

  FileCache get cache => Get.find();

  TagRelationService get relations => Get.find();

  Future<Result<void>> update(List<HydrusFile> files) async {

    for (final chunk in files.chunked(20)) {

      final result = await api
          .getFileMetadata(chunk.ids)
          .run()
          .mapElements(Tags.fromDto);

      if (result is Failure) return result;

      final tags = result.getOrThrow();

      for (var i = 0; i < chunk.length; i++) {
        chunk[i].tags = tags[i];
      }

      final load = tags.expand((t) => t.all.storage);

      final update = await relations.push(load);

      if (update is Failure) return update;
    }

    return Success(null);
  }

  Future<Result<void>> download(int id) =>
      api.getFile(id).then(Native.saveFile).run();
}
