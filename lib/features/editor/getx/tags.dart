import 'package:get/get.dart';
import 'package:hydit/entities/service.dart';

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

  Iterable<String> get services => _initial.keys;

  final _initial = <String, TagService>{};
  final _current = <String, RxSet<Tag>>{};

  Set<Tag> get initial => _initial[service.value]!.initial;
  Set<Tag> get current => _current[service.value]!;

  final FileStore files;

  TagManager(this.files);

  Repo get repo => Get.find();

  /// Union of original and added tags
  Set<Tag> get union => { ...initial, ...current };

  void select(String service) => this.service.value = service;

  /// Sorted tags to show in UI
  List<Tag> tags() => union
      .sortBuilder()
      .state(initial)
      .namespace()
      .alphabetical()
      .sort();

  /// Number of tags in [service] with additions and deletions
  int length(String service) => _current[service]!.length;

  /// State of specified tag: unchanged, added or removed
  TagState state(Tag tag) {
    final inO = initial.contains(tag);
    final inC = current.contains(tag);

    if (inO && inC) return .unchanged;
    if (!inO && inC) return .added;
    return .removed;
  }

  /// Number of files in [TagManager]
  int get fileCount => _ids.length;

  Set<Tag> get additions => current.difference(initial);

  Set<Tag> get deletions => initial.difference(current);

  /// Number of additions and deletions
  ({int add, int del}) diff([String? service]) {
    if (service == null) {
      return (add: additions.length, del: deletions.length);
    }

    final initial = _initial[service]!.initial;
    final current = _current[service]!;

    final add = current.difference(initial).length;
    final del = initial.difference(current).length;

    return (add: add, del: del);
  }

  /// Whether selected service is editable
  bool get editable => _initial[service.value]!.editable;

  void add(Tag tag) {
    if (!editable) return;
    if (tag.raw.isEmpty) return;
    current.add(tag);
  }

  void addRaw(String raw) => add(Tag(raw));

  void remove(Tag tag) {
    if (!editable) return;
    if (tag.raw.isEmpty) return;
    switch (state(tag)) {
      case .removed:
        current.add(tag);
      case _:
        current.remove(tag);
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

    _initial.assignAll(file.tags.value!);

    final current = file.tags.value!.map(
      (name, service) => MapEntry(name, service.initial.obs),
    );

    _current.assignAll(current);

    if (service != null) {
      this.service.value = service;
    }

    ready.value = true;
  }

  void initBatch(List<int> ids) {
    // TODO
    throw UnimplementedError();
  }

  // MARK: SAVE

  bool equal(Set<Tag> a, Set<Tag> b) {
    return a.length == b.length && a.difference(b).isEmpty;
  }

  /// No changes, editor can be safely closed
  bool get unlocked {

    for (final name in services) {
      final a = _initial[name]!.initial;
      final b = _current[name]!;
      if (!equal(a, b)) return false;
    }

    return true;
  }

  /// Send changes to Hydrus
  Future<Result<void>> save() => repo.apply(_ids, summarize());

  /// Generate [TagDiff]s for [save] method
  List<TagDiff> summarize() {
    final changes = <TagDiff>[];

    for (final MapEntry(key: name, value: service) in _initial.entries) {
      final current = _current[name]!;

      final add = current.difference(service.initial);
      final del = service.initial.difference(current);

      if (add.isEmpty && del.isEmpty) continue;

      final diff = TagDiff(
        key: service.key,
        added: add,
        deleted: del,
      );

      changes.add(diff);
    }

    return changes;
  }
}
