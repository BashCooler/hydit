import 'package:get/get.dart';

import 'package:hydit/services/repo.dart';
import 'package:hydit/services/executor.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/reactive/file_store.dart';

const readOnlyServices = ['all known tags', 'public tag repository'];


enum TagState {
  unchanged,
  added,
  removed,
}


class TagManager extends GetxController {
  final ready = false.obs;

  final services = <String>[];
  final _ids = <int>{};

  final _original = <Tag>{};
  final _current = <Tag>{}.obs;

  final FileStore files;

  TagManager(this.files);

  Repo get repo => Get.find();

  /// Allowed to safely pop the editor page
  bool get unlocked => additions.isEmpty && deletions.isEmpty;

  Set<Tag> current() => {
    ..._original,
    ..._current,
  };

  /// Sorted tags to show in UI
  List<Tag> tags() {
    final tags = _current.union(_original);

    return tags.sortBuilder()
        .state(_original)
        .namespace()
        .alphabetical()
        .sort();
  }

  /// Number of tags in specified service, if no service
  /// is specified returns current service length
  int length() {
    return current().where((t) => stateOf(t) != .removed).length;
  }

  /// State of specified tag: unchanged, added or removed
  TagState stateOf(Tag tag) {
    final original = _original.contains(tag);
    final current = _current.contains(tag);

    if (original && current) return .unchanged;
    if (!original && current) return .added;
    return .removed;
  }

  /// Number of files in [TagManager]
  int get fileCount => _ids.length;

  Set<Tag> get additions => _current.difference(_original);

  Set<Tag> get deletions => _original.difference(_current);

  /// Whether selected service is editable
  bool get editable => true; // TODO

  void add(Tag tag) {
    if (editable) return;
    if (tag.raw.isEmpty) return;
    _current.add(tag);
  }

  void addRaw(String raw) => add(Tag(raw));

  void remove(Tag tag) {
    if (editable) return;
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
}


extension Init on TagManager {
  bool get loading => !ready.value;

  Future<void> init(HydrusFile file, [String? service]) async {
    clear();

    _ids.assign(file.id);
    ready.value = false;

    if (file.loading) await file.ensureMetadataLoaded();
    if (file.id != _ids.first) return;

    final tags = file
        .meta!
        .combined[service];
    addToServices(tags);

    ready.value = true;
  }

  void initBatch(List<int> ids) {
    throw UnimplementedError();

    clear();
    _ids.assignAll(ids);

    for (final id in ids) {
      final file = files.byId(id);
      final tags = file
          .meta!
          .all
          .toSet();
      addToServices(tags);
    }

    // selectCurrentService();
    ready.value = true;
  }

  void clear() {
    services
      ..clear()
      ..addAll(repo.services.map((s) => s.name));

    _ids.clear();
    _current.clear();
    _original.clear();
  }

  void addToServices(Set<Tag>? tags) {
    if (tags == null) return;
    _original.addAll(tags);
    _current.addAll(tags);
  }
}


extension Save on TagManager {

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
