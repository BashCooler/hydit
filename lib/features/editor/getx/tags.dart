import 'package:get/get.dart';
import 'package:hydit/entities/service.dart';

import 'package:hydit/services/repo.dart';
import 'package:hydit/services/executor.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/reactive/file.dart';


enum TagState { unchanged, added, removed }


class TagManager extends GetxController {
  final ready = false.obs;

  final _ids = <int>{};
  final _files = <HydrusFile>[];

  final service = 'all known tags'.obs;

  Iterable<String> get services => _initial.keys;

  final _initial = <String, Set<Tag>>{};
  final _current = <String, RxSet<Tag>>{};

  Set<Tag> get initial => _initial[service.value]!;
  Set<Tag> get current => _current[service.value]!;

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

    final initial = _initial[service]!;
    final current = _current[service]!;

    final add = current.difference(initial).length;
    final del = initial.difference(current).length;

    return (add: add, del: del);
  }

  /// Use this to access fields like key, editable etc.
  Map<String, TagService> get original => _files.first.tags.value!;

  /// Whether selected service is editable
  bool get editable => original[service.value]!.editable;

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
  List<HydrusFile> take([int count = 4]) => _files
      .take(count)
      .toList();

  // MARK: INIT

  bool get loading => !ready.value;

  Future<void> init(HydrusFile file, [String? service]) async {
    ready.value = false;

    _ids.assign(file.id);
    _files.assign(file);

    if (file.loading) await file.ensureMetadataLoaded();
    if (file.id != _ids.first) return;

    final tags = file.tags.value!
        .map((k, v) => MapEntry(k, v.initial));

    _initial.assignAll(tags);
    _current.assignAll(tags.map((k, v) => MapEntry(k, v.obs)));

    if (service != null) {
      this.service.value = service;
    }

    ready.value = true;
  }

  void initBatch(List<HydrusFile> files) {
    ready.value = false;

    _ids.assignAll(files.map((f) => f.id));
    _files.assignAll(files);

    final Map<String, Set<Tag>> tags = {};

    for (final file in files) {
      final original = file.tags.value!.entries;

      for (final MapEntry(key: name, value: service) in original) {
        tags.putIfAbsent(name, () => {}).addAll(service.initial);
      }
    }

    _initial.assignAll(tags);
    _current.assignAll(tags.map((k, v) => MapEntry(k, v.obs)));

    ready.value = true;
  }

  // MARK: SAVE

  bool equal(Set<Tag> a, Set<Tag> b) {
    return a.length == b.length && a.difference(b).isEmpty;
  }

  /// No changes, editor can be safely closed
  bool get unlocked {

    for (final name in services) {
      final a = _initial[name]!;
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

      final add = current.difference(service);
      final del = service.difference(current);

      if (add.isEmpty && del.isEmpty) continue;

      final diff = TagDiff(
        key: original[name]!.key,
        added: add,
        deleted: del,
      );

      changes.add(diff);
    }

    return changes;
  }
}
