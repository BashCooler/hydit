import 'package:get/get.dart';

import 'package:hydit/services/repo.dart';
import 'package:hydit/services/mapper.dart';
import 'package:hydit/services/executor.dart';
import 'package:hydit/entities/metadata.dart';

import 'file_store.dart';


class HydrusFile {
  final int id;
  final metadata = Rxn<FileMetadata>();
  final _deleted = false.obs;

  HydrusFile(this.id);

  Future<Result<void>>? _loadingFuture;

  bool get loaded => metadata.value != null;
  bool get loading => metadata.value == null;
  bool get deleted => _deleted.value;

  FileMetadata? get meta => metadata.value;

  Repo get repo => Get.find();

  String get url => repo.buildUrl(id);
  String get thumbnailUrl => repo.buildUrl(id, thumbnail: true);

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
