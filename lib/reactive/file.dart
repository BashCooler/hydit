import 'package:get/get.dart';
import 'package:deep_pick/deep_pick.dart';

import 'package:hydit/entities/tag.dart';
import 'package:hydit/entities/tags.dart';
import 'package:hydit/entities/metadata.dart';
import 'package:hydit/services/services.dart';

import 'file_store.dart';


class HydrusFile {
  final FileMetadata meta;

  final Rx<Tags> tags;

  final Rx<bool> inbox;

  HydrusFile(this.meta, this.tags, this.inbox);

  /// The [map] parameter should be extracted from `file_metadata`
  /// response like so:
  ///
  /// `json -> metadata -> 0` (or other index)
  factory HydrusFile.fromMap(Map<String, dynamic> map) {

    final meta = FileMetadata.fromMap(map);
    final tags = Tags.fromMap(map);
    final inbox = pick(map, 'is_inbox').asBoolOrThrow();

    return HydrusFile(meta, tags.obs, inbox.obs);
  }

  /// The [pick] parameter should be extracted from `file_metadata`
  /// response like so:
  ///
  /// `pick(json, 'metadata', 0)` (or other index)
  factory HydrusFile.fromPick(Pick pick) {
    final map = pick.asMapOrThrow<String, dynamic>();

    return HydrusFile.fromMap(map);
  }

  Repo get repo => Get.find();

  Iterable<Tag> get all => tags.value['all known tags'] ?? [];

  int get id => meta.id;

  String get url => switch (meta.mime) {
    'image/jxl' when meta.duration == .zero => repo.render(id),
    _ => repo.buildUrl(id),
  };

  String get thumbnailUrl => repo.buildUrl(id, thumbnail: true);

  bool get isInbox => inbox.value;

  @override
  String toString() => 'HydrusFile ${meta.id}';

  Future<Result<void>> update() => repo.update([this]);

  final _removed = false.obs;

  bool get removed => _removed.value;

  /// Mark file as [removed].
  ///
  /// This method serves only to signal UI elements that file
  /// is being deleted. Make sure to remove it from [FileStore]
  /// manually to clear the resources.
  void remove() => _removed.value = true;

  Future<Result<void>> download() => repo.download(id);
}
