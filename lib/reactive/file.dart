import 'package:get/get.dart';
import 'package:deep_pick/deep_pick.dart';

import 'package:hydit/entities/tag.dart';
import 'package:hydit/entities/tags.dart';
import 'package:hydit/services/repo.dart';
import 'package:hydit/services/executor.dart';
import 'package:hydit/entities/metadata.dart';

import 'file_store.dart';


class HydrusFile {
  final FileMetadata meta;

  final Rx<Tags> tags;

  HydrusFile(this.meta, this.tags);

  /// The [map] parameter should be extracted from `file_metadata`
  /// response like so:
  ///
  /// `json -> metadata -> 0` (or other index)
  factory HydrusFile.fromMap(Map<String, dynamic> map) {

    final meta = FileMetadata.fromMap(map);
    final tags = Tags.fromMap(map);

    return HydrusFile(meta, tags.obs);
  }

  final Repo repo = Get.find();

  Iterable<Tag> get all => tags.value['all known tags']?.entries ?? [];

  int get id => meta.id;

  String get url => repo.buildUrl(id);

  String get thumbnailUrl => repo.buildUrl(id, thumbnail: true);

  // MARK: LOAD

  Future<Result<void>>? _loadingFuture;

  Future<Result<void>> update() async {
    return _loadingFuture ??= _loadMetadata();
  }

  Future<Result<void>> _loadMetadata() async {
    final result = await repo.api
        .getFileMetadata([id])
        .run();

    final json = result.unwrap();

    if (json != null) {
      final meta = pick(json, 'metadata', 0)
          .asMapOrThrow<String, dynamic>();

      tags.value = Tags.fromMap(meta);
    }

    _loadingFuture = null;

    return result;
  }

  // MARK: DELETE

  final _deleted = false.obs;

  bool get deleted => _deleted.value;

  /// Mark file as [deleted].
  ///
  /// This method serves only to signal UI elements that file
  /// is being deleted. Make sure to remove it from [FileStore]
  /// manually to clear the resources.
  void delete() => _deleted.value = true;
}
