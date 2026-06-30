import 'package:get/get.dart';
import 'package:deep_pick/deep_pick.dart';

import 'package:hydit/entities/tag.dart';
import 'package:hydit/entities/tags.dart';
import 'package:hydit/services/repo.dart';
import 'package:hydit/services/executor.dart';
import 'package:hydit/entities/metadata.dart';

import 'file_store.dart';


class HydrusFile {
  final int id;
  final FileMetadata meta;

  final tags = Rxn<Tags>();

  HydrusFile(this.id, this.meta);

  Repo repo = Get.find();

  Iterable<Tag> get all => tags.value?['all known tags']?.entries ?? [];

  String get url => repo.buildUrl(id);

  String get thumbnailUrl => repo.buildUrl(id, thumbnail: true);

  // MARK: LOAD

  bool get loaded => tags.value != null;
  bool get loading => tags.value == null;

  Future<Result<void>>? _loadingFuture;

  Future<void> ensureMetadataLoaded() {
    if (loaded) {
      return Future.value();
    }
    return update();
  }

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
