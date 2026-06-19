import 'package:get/get.dart';

import '../entities/metadata.dart';
import '../services/repo.dart';


class HydrusFile {
  final int id;
  final metadata = Rxn<FileMetadata>();

  HydrusFile(this.id);

  Future<void>? _loadingFuture;

  bool get loaded => metadata.value != null;
  bool get loading => metadata.value == null;

  FileMetadata? get meta => metadata.value;

  Repo get repo => Get.find();

  String get url => repo.buildUrl(id);
  String get thumbnailUrl => repo.buildUrl(id, thumbnail: true);

  Future<void> ensureMetadataLoaded() async {
    if (loaded) {
      return Future.value();
    }

    if (_loadingFuture != null) {
      return _loadingFuture;
    }

    return _loadingFuture ??= _loadMetadata();
  }

  Future<void> _loadMetadata() {
    return Get
        .find<Repo>()
        .setMetadataFor(this)
        .then((_) => _loadingFuture = null);
  }
}