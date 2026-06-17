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

  Future<void>? _metadataFuture;

  bool get loaded => metadata.value != null;
  bool get loading => metadata.value == null;

  FileMetadata? get meta => metadata.value;

  Future<void> loadMetadata() async {
    if (loaded) {
      return;
    }

    if (_metadataFuture != null) {
      return _metadataFuture;
    }

    _metadataFuture = Get
        .find<Repo>()
        .setMetadataFor(this)
        .then((r) => _metadataFuture = null);
  }
}