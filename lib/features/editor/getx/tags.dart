import 'package:get/get.dart';

import 'package:hydit/core/data/repo.dart';
import 'package:hydit/core/domain/entities.dart';
import 'package:hydit/core/domain/file_repo.dart';

const readOnlyServices = ['all known tags', 'public tag repository'];


class TagManager extends GetxController {
  final ready = false.obs;

  final services = <String>[];
  final selectedService = ''.obs;
  final _ids = <int>{};
  final sort = Sort.alphabeticalAsc.obs;

  final Set<Tag> _original = {};
  final Set<Tag> _tags = {};
  final Set<Tag> _tagsToAdd = {};
  final Set<Tag> _tagsToRemove = {};

  final FileRepo files;

  TagManager(this.files);

  /// Selected service
  String get service => selectedService.value;

  /// Returns tags of specified [service], if [service] is null
  /// returns tags of currently selected service
  Iterable<Tag> tags([String? service]) {
    switch (service) {
      case null:
        if (this.service == 'all known tags') return unique();
        return _tags[this.service];
      case 'all known tags':
        return unique();
      case _:
        return _tags[service];
    }
  }

  /// Number of tags in specified service
  int lengthOf(String service) {
    return tags(service).length;
  }

  /// Generates `all known tags` dynamically to
  /// reflect changes in other services
  Set<Tag> unique() {
    final Map<String, Tag> map = {
      for (var tag in _tags) tag.raw : tag
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

  /// Number of tags in the selected service including existing tags
  /// and tags to add
  int get total {
    return tags().length + _tagsToAdd[service].length;
  }

  /// Number of files in [TagManager]
  int get fileCount => _ids.length;

  /// Number of tags to add to the selected service
  int get additionsCount => _tagsToAdd[service].length;

  /// Number of tags to remove from the selected service
  int get deletionsCount => _tagsToRemove[service].length;

  /// Whether selected service is editable
  bool get editable => isServiceEditable(service);

  void add(Tag tag) {
    if (!isServiceEditable(service)) return;

    final t = tag.copyWith(service: service);
    if (t.raw.isEmpty) return;
    if (_tags.contains(t)) return;

    switch (_original.contains(t)) {
      case true:
        _tags.add(t);
        _tagsToRemove.remove(t);
      case false:
        _tagsToAdd.add(t);
    }
    update();
  }

  void delete(Tag tag) {
    if (!isServiceEditable(service)) return;

    final t = tag.copyWith(service: service);
    final hasTag = _tags.contains(t) || _tagsToAdd.contains(t);
    if (!hasTag) return;

    _tags.remove(t);
    _tagsToAdd.remove(t);
    _tagsToRemove.add(t);
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
    _tags.clear();
    _tagsToAdd.clear();
    _tagsToRemove.clear();
  }

  void addToServices(Set<Tag>? tags) {
    if (tags == null) return;
    _original.assignAll(tags);
    _tags.addAll(tags);
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

    if (_tagsToAdd.isEmpty && _tagsToRemove.isEmpty) {
      return 'No changes';
    }

    final sb = StringBuffer();

    if (_tagsToAdd.isNotEmpty) {
      final servicesToAddTo = _tagsToAdd
          .map((t) => t.service)
          .toSet()
          .length;
      final count = _tagsToAdd.length;
      sb.writeln('Add $count tags to $servicesToAddTo services');
    }

    if (_tagsToRemove.isNotEmpty) {
      final servicesToRemoveFrom = _tagsToRemove
          .map((t) => t.service)
          .toSet()
          .length;
      final count = _tagsToRemove.length;
      sb.writeln('Remove $count tags from $servicesToRemoveFrom services');
    }

    return sb.toString();
  }

  /*
  /// Send request to Hydrus to add/remove tags
  Future<void> save() async {
    final toAdd = removeEmpty(_tagsToAdd);
    final toRem = removeEmpty(_tagsToRemove);

    final Repo repo = Get.find();

    for (final entry in toAdd.entries) {
      var service = entry.key;
      service = await repo.getServiceByName(service);
      final tags = entry.value.map((e) => e.raw).toList();
      await repo.addTags(_ids.toList(), service, tags);
    }

    for (final entry in toRem.entries) {
      var service = entry.key;
      service = await repo.getServiceByName(service);
      final tags = entry.value.map((e) => e.raw).toList();
      await repo.removeTags(_ids.toList(), service, tags);
    }

    for (final id in _ids) {
      await repo.setMetadataFor(files.byId(id));
    }
  }
   */
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


enum Sort { alphabeticalAsc, alphabeticalDesc }

extension Sorting on TagManager {
  /*
  void sortTags() {
    switch (sort.value) {
      case .alphabeticalAsc:
        tags().toList().sort((a, b) => a.raw.compareTo(b.raw));
      case .alphabeticalDesc:
        tags().toList().sort((a, b) => b.raw.compareTo(a.raw));
    }
    update();
  }
   */
}
