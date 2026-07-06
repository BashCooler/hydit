import 'package:get/get.dart';

import 'package:hydit/entities/tag.dart';
import 'package:hydit/entities/service.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/services/repo.dart';


enum TagState { unchanged, added, removed }


abstract class TagManagerBase {
  Repo get repo => Get.find();

  final _initial = <String, Set<Tag>>{};
  final _current = <String, RxSet<Tag>>{}.obs;

  Set<Tag> get initial => _initial[service.value]!;
  Set<Tag> get current => _current[service.value]!;

  /// Use this to access fields like key, editable etc.
  Map<String, TagService> get original;

  /// Whether selected service is editable
  bool get editable => original[service.value]!.editable;

  /// Union of original and added tags.
  Set<Tag> get union => { ...initial, ...current };

  Set<Tag> get additions => current.difference(initial);

  Set<Tag> get deletions => initial.difference(current);

  void assign(Map<String, Set<Tag>> tags) {
    _initial.assignAll(tags);
    _current.assignAll(tags.map((k, v) => MapEntry(k, v.obs)));
  }

  final service = 'all known tags'.obs;

  Iterable<String> get services => _initial.keys;

  int get fileCount;

  void select(String service) => this.service.value = service;

  void add(Tag tag);

  void addRaw(String raw) => add(Tag(raw));

  void remove(Tag tag);

  int count(Tag tag);

  /// Number of tags in [service] with additions and deletions.
  int length(String service) => _current[service]!.length;

  /// Sorted tags to show in UI
  List<Tag> tags() => union
      .sortBuilder()
      .state(initial)
      .namespace()
      .alphabetical()
      .sort();

  /// State of specified tag: unchanged, added or removed.
  TagState state(Tag tag);

  bool equal(Set<Tag> a, Set<Tag> b) {
    return a.length == b.length && a.difference(b).isEmpty;
  }

  /// Take from 0 to [count] files from [TagManager].
  List<HydrusFile> take([int count = 4]);

  /// No changes, editor can be safely closed.
  bool get unlocked {

    for (final name in services) {
      final a = _initial[name]!;
      final b = _current[name]!;
      if (!equal(a, b)) return false;
    }

    return true;
  }

  /// Generate [TagDiff]s.
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

  /// Number of additions and deletions.
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
}