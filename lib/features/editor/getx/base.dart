import 'package:get/get.dart';

import 'package:hydit/api/models.dart';
import 'package:hydit/api/params.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/services/executor.dart';
import 'package:hydit/services/repo.dart';
import 'package:hydit/utils/tag_sort.dart';
import 'package:hydit/utils/utils.dart';

import '../entities/changes.dart';


enum TagState { unchanged, added, removed }


abstract class TagManager {
  Repo get repo => Get.find();

  final _initial = <String, Set<Tag>>{};
  final _current = <String, RxSet<Tag>>{}.obs;

  Set<Tag> get initial => _initial[_service.value]!;
  Set<Tag> get current => _current[_service.value]!;

  /// Files in this [TagManager].
  List<HydrusFile> get files;

  /// Use this to access fields like key, editable etc.
  Map<String, TagService> get original;

  /// Whether selected service is editable
  bool get editable => original[_service.value]!.editable;

  /// The key of currently selected service.
  String get key => original[service]!.key;

  /// The key of [service].
  String keyOf(String service) => original[service]!.key;

  /// Union of original and added tags.
  Set<Tag> get union => { ...initial, ...current };

  /// Assign initial tags, which will be edited.
  Map<String, Set<Tag>> initTags();

  /// Remove all tags from this [TagManager] and initialize
  /// it with tags from [initTags].
  void init() => assign(initTags());

  void assign(Map<String, Set<Tag>> tags) {
    _initial.assignAll(tags);
    _current.assignAll(tags.map((k, v) => MapEntry(k, v.obs)));
  }

  final _service = 'all known tags'.obs;

  String get service => _service.value;

  set service(String? service) {
    if (service == null) return;
    if (services.contains(service)) _service.value = service;
  }

  Iterable<String> get services => _initial.keys;

  void add(Tag tag) {
    if (!editable) return;
    if (tag.raw.isEmpty) return;
    current.add(tag);
  }

  void addRaw(String raw) => add(Tag(raw));

  /// Delete or restore the [tag].
  ///
  /// DO check if the current service is [editable]
  /// before applying any changes.
  ///
  /// DO check the [tag.raw] is not empty.
  void toggle(Tag tag);

  int count(Tag tag);

  /// Number of tags in [service] with additions and deletions.
  int length(String service) => _current[service]!.length;

  /// Sorted tags to show in UI
  List<Tag> get tags => TagSortBuilder(union)
      .state(initial)
      .namespace()
      .alphabetical()
      .sort();

  /// State of specified tag: unchanged, added or removed.
  TagState state(Tag tag) {
    final inO = initial.contains(tag);
    final inC = current.contains(tag);

    if (inO && inC) return .unchanged;
    if (!inO && inC) return .added;
    return .removed;
  }

  bool equal(Set<Tag> a, Set<Tag> b) {
    return a.length == b.length && a.difference(b).isEmpty;
  }

  /// No changes, editor can be safely closed.
  bool get unlocked {

    for (final name in services) {
      final a = _initial[name]!;
      final b = _current[name]!;
      if (!equal(a, b)) return false;
    }

    return true;
  }

  Set<Tag> additions(String service) {
    final current = _current[service]!;
    final initial = _initial[service]!;

    return current.difference(initial);
  }

  Set<Tag> deletions(String service) {
    final current = _current[service]!;
    final initial = _initial[service]!;

    return initial.difference(current);
  }

  /// Number of additions and deletions.
  (int, int) diff(String service) {
    final add = additions(service);
    final del = deletions(service);

    return (add.length, del.length);
  }

  /// Generate [Changes]s.
  Iterable<Changes> get _changes sync* {
    for (final service in _initial.keys) {
      final add = additions(service);
      final del = deletions(service);

      if (add.isEmpty && del.isEmpty) continue;

      yield Changes(key: keyOf(service), add: add, del: del);
    }
  }

  /// Send changes to Hydrus and update local files
  /// metadata.
  Future<Result<void>> save() => AddTagsParams(files.ids, _changes)
      .let(repo.api.postAddTags)
      .run()
      .flatMap((_) => repo.update(files));
}