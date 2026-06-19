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
  final selectedService = ''.obs;
  final _ids = <int>{};

  final Set<Tag> _original = {};
  final Set<Tag> _current = {};

  final FileStore files;

  TagManager(this.files);

  /// Selected service
  String get service => selectedService.value;

  /// Sorted tags to show in UI
  List<Tag> tags([String? service]) {
    final Iterable<Tag> set = _tags(service);
    return set.sort.state(_original).alphabetical().build();
  }

  /// Returns tags of specified [service], if [service] is null
  /// returns tags of currently selected service
  Iterable<Tag> _tags([String? service]) {
    switch (service) {
      case null:
        if (this.service == 'all known tags') return unique();
        return _current[this.service].union(_original[this.service]);
      case 'all known tags':
        return unique();
      case _:
        return _current[service].union(_original[service]);
    }
  }

  /// Number of tags in specified service, if no service
  /// is specified returns current service length
  int lengthOf([String? service]) {
    if (service == null) return _tags().length;
    return _tags(service).where((t) => stateOf(t) != .removed).length;
  }

  /// State of specified tag: unchanged, added or removed
  TagState stateOf(Tag tag) {
    final original = _original.contains(tag);
    final current = _current.contains(tag);

    if (original && current) return .unchanged;
    if (!original && current) return .added;
    return .removed;
  }

  /// Generates `all known tags` dynamically to
  /// reflect changes in other services
  Set<Tag> unique() {
    final Map<String, Tag> map = {
      for (var tag in _current) tag.raw : tag
    };
    return map.values.toSet();
  }

  /// Index of the selected service
  int get index {
    if (services.isEmpty) return 0;
    final index = services.indexOf(service);
    if (index < 0) return 0;
    return index;
  }

  /// Number of files in [TagManager]
  int get fileCount => _ids.length;

  Set<Tag> get additions => _current.difference(_original);

  Set<Tag> get deletions => _original.difference(_current);

  /// Whether selected service is editable
  bool get editable => isServiceEditable(service);

  void add(Tag tag) {
    if (!isServiceEditable(service)) return;

    final t = tag.copyWith(service: service);
    if (t.raw.isEmpty) return;

    _current.add(t);
    update();
  }

  void addRaw(String raw) {
    final t = Tag(raw);
    add(t);
  }

  void remove(Tag tag) {
    if (!isServiceEditable(service)) return;

    final t = tag.copyWith(service: service);
    if (t.raw.isEmpty) return;
    switch (stateOf(t)) {
      case .removed:
        _current.add(t);
      case _:
        _current.remove(t);
    }
    update();
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

  Future<void> init(HydrusFile file) async {
    clear();

    _ids.assign(file.id);
    ready.value = false;
    update();

    if (file.loading) await file.ensureMetadataLoaded();
    if (file.id != _ids.first) return;

    final tags = file
        .meta!
        .combined
        .where((e) => e.service != 'all known tags')
        .toSet();
    addToServices(tags);
    selectCurrentService();

    ready.value = true;
    update();
  }

  void initBatch(List<int> ids) {
    clear();
    _ids.assignAll(ids);

    for (final id in ids) {
      final file = files.byId(id);
      final tags = file
          ?.meta!
          .combined
          .where((e) => e.service != 'all known tags')
          .toSet();
      addToServices(tags);
    }

    selectCurrentService();
    ready.value = true;
    update();
  }

  void clear() {
    final all = Get.find<Repo>().services;
    services..clear()..addAll(all.keys);

    _ids.clear();
    _current.clear();
    _original.clear();
  }

  void addToServices(Set<Tag>? tags) {
    if (tags == null) return;
    _original.addAll(tags);
    _current.addAll(tags);
  }

  void selectCurrentService() {
    selectedService.value = selectedService.value != ''
        ? selectedService.value
        : services.first;
  }
}


extension Save on TagManager {
  /// Removes entries with empty lists from map
  Map<String, List<Tag>> removeEmpty(Map<String, List<Tag>> map) =>
      Map.from(map)..removeWhere((k, v) => v.isEmpty);

  /// Returns "No changes" if no changes were made, otherwise returns:
  /// ```
  /// Add X tags to Y services
  /// Remove X tags from Y services
  /// ```
  /// if X and Y are not zero.
  String summarize() {
    assert(_ids.isNotEmpty);

    final add = additions;
    final del = deletions;

    if (add.isEmpty && del.isEmpty) return 'No changes';

    final sb = StringBuffer();

    if (add.isNotEmpty) {
      final services = add.services.length;
      final count = add.length;
      sb.writeln('Add $count tags to $services services');
    }

    if (del.isNotEmpty) {
      final services = del.services.length;
      final count = del.length;
      sb.writeln('Remove $count tags from $services services');
    }

    return sb.toString();
  }

  /// Send request to Hydrus to add/remove tags.
  ///
  /// If process finishes successfully returns true.
  Future<bool> save() async {
    final Repo repo = Get.find();

    final added = await repo.addTags(_ids.toList(), additions);

    switch (added) {
      case Success(data: final _):
        break;
      case Failure(title: final _, message: final _):
        return false;
    }

    final removed = await repo.removeTags(_ids.toList(), deletions);

    switch (removed) {
      case Success(data: final _):
        break;
      case Failure(title: final _, message: final _):
        return false;
    }

    for (final id in _ids) {
      await repo.setMetadataFor(files.byId(id));
    }

    return true;
  }
}


extension ServiceUtils on TagManager {
  bool isServiceEditable(String service) {
    return !readOnlyServices.contains(service);
  }

  void selectServiceByIndex(int index) {
    if (index < 0 || index >= services.length) return;
    selectedService.value = services[index];
    update();
  }

  String pretty(String service) => switch (service) {
    'all known tags' => 'All',
    'public tag repository' => 'PTR',
    'downloader tags' => 'Downloader',
    _ => service,
  };
}
