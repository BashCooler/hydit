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
  final Set<Tag> _tagsToDelete = {};

  final FileRepo files;

  TagManager(this.files);

  /// Selected service
  String get service => selectedService.value;

  /// Selected service's tags
  List<Tag> get tags => _tags[service].toList();

  int lengthOf(String service) => _tags[service].length;

  List<int> get fileIds => _ids.toList();

  /// Selected service's index
  int get index {
    if (services.isEmpty) return 0;
    final index = services.indexOf(service);
    if (index < 0) return 0;
    return index;
  }

  /// Selected service's tags length
  int get total => _tags[service].length + _tagsToAdd[service].length;

  /// Number of current files to edit
  int get fileCount => _ids.length;

  /// Selected service's tags to add length
  int get additionsCount => _tagsToAdd[service].length;

  /// Selected service's tags to delete length
  int get deletionsCount => _tagsToDelete[service].length;

  /// If selected service is editable returns true
  bool get editable => isServiceEditable(service);

  void add(Tag tag) {
    if (!isServiceEditable(service)) return;

    final t = tag.copyWith(service: service);
    if (t.raw.isEmpty) return;
    if (_tags.contains(t)) return;

    switch (_original.contains(t)) {
      case true:
        _tags.add(t);
        _tagsToDelete.remove(t);
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
    _tagsToDelete.add(t);
    update();
  }
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

    addToServices(file.combined);
    selectCurrentService();

    ready.value = true;
    update();
  }

  void initBatch(List<int> ids) {
    clear();
    _ids.assignAll(ids);

    for (final id in ids) {
      final file = files.byId(id);
      addToServices(file?.combined);
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
    _tagsToDelete.clear();
  }

  void addToServices(Set<Tag>? combined) {
    if (combined == null) return;
    _original.assignAll(combined);
    _tags.addAll(combined);
  }

  void selectCurrentService() {
    selectedService.value = selectedService.value != ''
        ? selectedService.value
        : services.first;
  }
}

/*
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

    final toAdd = removeEmpty(_tagsToAdd);
    final toRem = removeEmpty(_tagsToDelete);

    if (toAdd.isEmpty && toRem.isEmpty) {
      return 'No changes';
    }

    final sb = StringBuffer();

    final addCount = toAdd.values.fold(
      0,
      (sum, list) => (sum + list.length).toInt(),
    );
    final serCount = toAdd.length;
    if (addCount > 0) {
      sb.writeln('Add $addCount tags to $serCount services');
    }

    final remCount = toRem.values.fold(
      0,
      (sum, list) => (sum + list.length).toInt(),
    );
    final serRem = toRem.length;
    if (remCount > 0) {
      sb.writeln('Remove $remCount tags from $serRem services');
    }

    return sb.toString();
  }

  /// Send request to Hydrus to add/remove tags
  Future<void> save() async {
    final toAdd = removeEmpty(_tagsToAdd);
    final toRem = removeEmpty(_tagsToDelete);

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
}
 */


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
  void sortTags() {
    switch (sort.value) {
      case .alphabeticalAsc:
        tags.sort((a, b) => a.raw.compareTo(b.raw));
      case .alphabeticalDesc:
        tags.sort((a, b) => b.raw.compareTo(a.raw));
    }
    update();
  }

  List<HydrusFile> slice() {
    return _ids
        .take(4)
        .map((id) => files.byId(id))
        .whereType<HydrusFile>()
        .toList();
  }
}
