import 'package:get/get.dart';

import 'package:hydit/services/repo.dart';
import 'package:hydit/services/executor.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/reactive/file_store.dart';


enum TagState {
  unchanged,
  added,
  removed,
}


class TagManager extends GetxController {
  final ready = false.obs;

  final _ids = <int>{};

  final service = 'all known tags'.obs;

  final _combined = <String, Set<Tag>>{};
  Iterable<String> get services => _combined.keys;

  final _original = <Tag>{};
  final _current = <Tag>{}.obs;

  final FileStore files;

  TagManager(this.files);

  Repo get repo => Get.find();

  int lengthOf(String service) => _combined[service]!.length;

  /// Union of original and added tags
  Set<Tag> current() => { ..._original, ..._current };

  /// Sorted tags to show in UI
  List<Tag> tags() => current()
      .sortBuilder()
      .state(_original)
      .namespace()
      .alphabetical()
      .sort();

  /// Number of tags in service with additions and deletions
  int length() => current().difference(deletions).length;

  /// State of specified tag: unchanged, added or removed
  TagState stateOf(Tag tag) {
    final inO = _original.contains(tag);
    final inC = _current.contains(tag);

    if (inO && inC) return .unchanged;
    if (!inO && inC) return .added;
    return .removed;
  }

  /// Number of files in [TagManager]
  int get fileCount => _ids.length;

  Set<Tag> get additions => _current.difference(_original);

  Set<Tag> get deletions => _original.difference(_current);

  /// Whether selected service is editable
  bool get editable => true; // TODO

  void add(Tag tag) {
    if (!editable) return;
    if (tag.raw.isEmpty) return;
    _current.add(tag);
  }

  void addRaw(String raw) => add(Tag(raw));

  void remove(Tag tag) {
    if (!editable) return;
    if (tag.raw.isEmpty) return;
    switch (stateOf(tag)) {
      case .removed:
        _current.add(tag);
      case _:
        _current.remove(tag);
    }
  }

  /// Take from 0 to [count] files from [TagManager]
  List<HydrusFile> take([int count = 4]) => _ids
      .take(count)
      .map((id) => files.byId(id))
      .whereType<HydrusFile>()
      .toList();

  // MARK: INIT

  bool get loading => !ready.value;

  Future<void> init(HydrusFile file, [String? service]) async {
    ready.value = false;

    _ids.assign(file.id);

    if (file.loading) await file.ensureMetadataLoaded();
    if (file.id != _ids.first) return;

    final combined = file.meta!.combined;
    _combined.assignAll(combined);

    final tags = combined[service ?? this.service.value]!;
    if (service != null) {
      this.service.value = service;
    }

    _original.assignAll(tags);
    _current.assignAll(tags);

    ready.value = true;
  }

  void initBatch(List<int> ids) {
    // TODO
    throw UnimplementedError();
  }

  // MARK: SAVE

  /// Allowed to safely pop the editor page
  bool get unlocked => additions.isEmpty && deletions.isEmpty;

  String? summarize() {
    assert(_ids.isNotEmpty);

    if (unlocked) return null;

    final sb = StringBuffer();

    if (additions.isNotEmpty) {
      final services = additions.services.length;
      final count = additions.length;
      sb.write('Add $count tags to $services services\n');
    }

    if (deletions.isNotEmpty) {
      final services = deletions.services.length;
      final count = deletions.length;
      sb.write('Remove $count tags from $services services');
    }

    return sb.toString();
  }

  Future<Result<void>> save() {
    return ExecutorBatch()
        .queue(repo.addTags(_ids, additions))
        .queue(repo.removeTags(_ids, deletions))
        .queueAll(_ids.map(files.updateById))
        .run();
  }
}
