import 'package:get/get.dart';

import 'package:hydit/core/data/repo.dart';
import 'package:hydit/core/domain/entities.dart';
import 'package:hydit/core/domain/file_repo.dart';

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

  final FileRepo files;

  TagManager(this.files);

  /// Selected service
  String get service => selectedService.value;

  /// Sorted tags to show in UI
  List<Tag> tags([String? service]) {
    final Iterable<Tag> set = _tags(service);
    return set.toList()..sort((a, b) {
      final aAdded = !_original.contains(a);
      final bAdded = !_original.contains(b);

      if (aAdded != bAdded) return aAdded ? -1 : 1;

      return a.raw.compareTo(b.raw);
    });
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

  /// Number of tags to add to the selected service
  int get additionsCount => -1;  // TODO

  /// Number of tags to remove from the selected service
  int get deletionsCount => -1;  // TODO

  /// Whether selected service is editable
  bool get editable => isServiceEditable(service);

  void add(Tag tag) {
    if (!isServiceEditable(service)) return;

    final t = tag.copyWith(service: service);
    if (t.raw.isEmpty) return;

    _current.add(t);
    update();
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

    await file.checkForMetadata();
    if (file.id != _ids.first) return;

    final tags = file
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
          ?.combined
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
    services..clear()..addAll(all);

    _ids.clear();
    _current.clear();
  }

  void addToServices(Set<Tag>? tags) {
    if (tags == null) return;
    _original.assignAll(tags);
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

    return 'Not implemented';  // TODO
    /*
    if (_tagsToAdd.isEmpty && _tagsToRemove.isEmpty) {
      return 'No changes';
    }

    final sb = StringBuffer();

    if (_tagsToAdd.isNotEmpty) {
      final services = _tagsToAdd.services.length;
      final count = _tagsToAdd.length;
      sb.writeln('Add $count tags to $services services');
    }

    if (_tagsToRemove.isNotEmpty) {
      final services = _tagsToRemove.services.length;
      final count = _tagsToRemove.length;
      sb.writeln('Remove $count tags from $services services');
    }

    return sb.toString();
    */
  }

  /// Send request to Hydrus to add/remove tags
  Future<void> save() async {
    final Repo repo = Get.find();
    throw UnimplementedError();  // TODO

    /*
    await repo.addTags(_ids.toList(), _tagsToAdd);
    await repo.removeTags(_ids.toList(), _tagsToRemove);

    for (final id in _ids) {
      await repo.setMetadataFor(files.byId(id));
    }
     */
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
