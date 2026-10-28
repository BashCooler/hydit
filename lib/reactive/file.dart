import 'package:get/get.dart';

import 'package:hydit/api/models.dart';
import 'package:hydit/entities/tags.dart';
import 'package:hydit/entities/metadata.dart';
import 'package:hydit/services/services.dart';

import 'file_store.dart';


class HydrusFile._(
  final FileMetadata meta,
  final Rx<Tags> _tags,
  final Rx<bool> inbox,
) {
  factory fromDto(FileMetadataDto dto) => HydrusFile._(
    FileMetadata.fromDto(dto),
    Tags.fromDto(dto).obs,
    dto.inbox.obs,
  );

  Repo get repo => Get.find();

  /// The [Tags] object of this file.
  Tags get tags => _tags.value;

  set tags(Tags t) => _tags.value = t;

  /// Return `all known tags` service.
  TagService get all => tags.all;

  int get id => meta.id;

  /// The url to the file itself.
  String get url => repo.api.getFileUrl(
    id,
    type: switch (meta.mime) {
      'image/jxl' when meta.duration == .zero => .render,
      _ => .file,
    },
  );

  /// The url to the file's thumbnail itself.
  String get thumbnailUrl => repo.api.getFileUrl(id, type: .thumbnail);

  bool get isInbox => inbox.value;

  @override
  String toString() => 'HydrusFile $id';

  final _removed = false.obs;

  /// The file is about to be removed and all operations with
  /// it should be discarded.
  bool removing = false;

  /// The file should be hidden from UI.
  bool get removed => _removed.value;

  /// Mark file as [removed].
  ///
  /// This method serves only to signal UI elements that file
  /// is being deleted. Make sure to remove it from [FileStore]
  /// manually to clear the resources.
  void remove() {
    removing = true;
    _removed.value = true;
  }

  Future<Result<void>> download() => repo.download(id);

  Future<Result<void>>? _togglingInbox;

  /// Move inboxed file to archive or move archived file to
  /// the inbox.
  Future<Result<void>> toggleInbox() => _togglingInbox ??= repo.api
      .editFiles([id], action: isInbox ? .archive : .inbox)
      .run()
      .tapSuccess((_) => inbox.toggle())
      .whenComplete(() => _togglingInbox = null);
}


extension Ids on Iterable<HydrusFile> {
  List<int> get ids => map((f) => f.id).toList();
}
