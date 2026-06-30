import 'package:get/get.dart';

import 'package:hydit/entities/tag.dart';
import 'package:hydit/entities/tags.dart';
import 'package:hydit/services/repo.dart';
import 'package:hydit/services/mapper.dart';
import 'package:hydit/services/executor.dart';
import 'package:hydit/entities/metadata.dart';

import 'file_store.dart';


class HydrusFile {
  final int id;

  final metadata = Rxn<FileMetadata>();

  final tags = Rxn<Tags>();

  HydrusFile(this.id);

  Repo repo = Get.find();

  FileMetadata? get meta => metadata.value;

  Iterable<Tag> get all => tags.value?['all known tags']?.entries ?? [];

  String get url => repo.buildUrl(id);

  String get thumbnailUrl => repo.buildUrl(id, thumbnail: true);

  // MARK: LOAD

  bool get loaded => metadata.value != null;
  bool get loading => metadata.value == null;

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

  Future<Result<void>> _loadMetadata() {
    return repo.api
        .getFileMetadata([id])
        .run()
        .tapSuccess((data) => Mapper.writeMetadata(data, this))
      ..then((_) => _loadingFuture = null);
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


extension ToFile on int {
  HydrusFile toFile() => HydrusFile(this);
}
