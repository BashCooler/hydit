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

  final _original = <Tag>{};
  final _current = <Tag>{}.obs;

  final FileStore files;

  TagManager(this.files);

  Repo repo = Get.find();

  /// Selected service
  String get service => selectedService.value;

  /// Allowed to safely pop the editor page
  bool get unlocked => additions.isEmpty && deletions.isEmpty;

  /// Sorted tags to show in UI
  List<Tag> tags([String? service]) {
    return _tags(service).sortBuilder()
        .state(_original)
        .namespace()
        .alphabetical()
        .sort();
  }

  /// Returns tags of specified [service], if [service] is null
  /// returns tags of currently selected service
  Iterable<Tag> _tags([String? service]) {
    switch (service) {
      case null when this.service == 'all known tags':
        return unique();
      case null:
        return _current
            .of(this.service)
            .union(_original.of(this.service));
      case 'all known tags':
        return unique();
      case _:
        return _current
            .of(service)
            .union(_original.of(service));
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

    if (file.loading) await file.ensureMetadataLoaded();
    if (file.id != _ids.first) return;

    final tags = file
        .meta!
        .all
        .toSet();
    addToServices(tags);
    selectCurrentService();

    ready.value = true;
  }

  void initBatch(List<int> ids) {
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

    selectCurrentService();
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

  void selectCurrentService() {
    selectedService.value = selectedService.value != ''
        ? selectedService.value
        : services.first;
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


extension ServiceUtils on TagManager {
  bool isServiceEditable(String service) {
    return !readOnlyServices.contains(service);
  }

  void selectServiceByIndex(int index) {
    if (index < 0 || index >= services.length) return;
    selectedService.value = services[index];
  }

  String pretty(String service) => switch (service) {
    'all known tags' => 'All',
    'public tag repository' => 'PTR',
    'downloader tags' => 'Downloader',
    _ => service,
  };
}
