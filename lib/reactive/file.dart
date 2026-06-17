import 'package:get/get.dart';

import '../entities/metadata.dart';
import '../services/repo.dart';


class HydrusFile {
  final int id;
  final metadata = Rxn<FileMetadata>();
  final String thumbnailUrl;
  final String url;

  HydrusFile({
    required this.id,
    required this.thumbnailUrl,
    required this.url,
  });

  Future<void>? _loadingFuture;

  bool get loaded => metadata.value != null;
  bool get loading => metadata.value == null;

  FileMetadata? get meta => metadata.value;

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