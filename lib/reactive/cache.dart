import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'package:hydit/api/models.dart';
import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/services/services.dart';


class FileCache {

  final cache = <int, HydrusFile>{};

  /// Subscribe to this [Rx] with [Worker] to get
  /// notified on file deletion.
  final deleted = <int>[].rx;

  Api get api => Get.find();

  TagRelationService get relations => Get.find();

  HydrusFile? operator [](int id) => cache[id];

  void assignAll(Map<int, HydrusFile> val) => cache.assignAll(val);

  void addAll(Map<int, HydrusFile> val) => cache.addAll(val);

  void clear() => cache.clear();

  List<HydrusFile> withIds(List<int> ids) => ids
      .map((id) => cache[id])
      .whereType<HydrusFile>()
      .toList();

  /// Update metadata of files with [ids].
  ///
  /// Throws [DioException].
  Future<void> update(List<int> ids) async {
    await for (final chunk in api.getFileMetadataChunks(ids)) {
      for (final dto in chunk) {
        cache[dto.id]?.metadata = dto;
      }
      await relations.push(chunk.expand((dto) => dto.tags.all.storage));
    }
  }

  /// Remove files with provided [ids].
  ///
  /// Use [getOffAll] when deleting the last file to
  /// get to the home screen.
  Future<void> remove(List<int> ids, {
    bool getOffAll = false,
  }) async {

    final toRemove = ids.map((id) => cache[id]!);

    for (final file in toRemove) {
      file.removing = true;
    }

    if (getOffAll) {
      Get.until((route) => route.isFirst);
      await sleep(transition);
    }

    for (final file in toRemove) {
      file.remove();
    }

    await sleep(deletionDuration + 100.ms);

    deleted.value = ids;

    for (final file in toRemove) {
      cache.remove(file.id);
    }
  }
}
