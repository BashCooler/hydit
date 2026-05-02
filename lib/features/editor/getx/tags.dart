import 'package:get/get.dart';
import 'package:hydrus_flutter/core/data/repo.dart';
import 'package:hydrus_flutter/core/domain/entities.dart';

const readOnlyServices = ['all known tags', 'public tag repository'];


class TagManager extends GetxController {
  final services = <String>[];
  final selectedService = ''.obs;
  final sort = Sort.alphabeticalAsc.obs;

  final Map<String, List<Tag>> _tags = {};
  final Map<String, List<Tag>> _tagsToAdd = {};
  final Map<String, List<Tag>> _tagsToDelete = {};

  /// Selected service
  String get service => selectedService.value;

  /// Selected service's tags
  List<Tag> get tags => _tags[service] ?? [];

  /// Selected service's index
  int get index {
    if (services.isEmpty) return 0;
    final index = services.indexOf(service);
    if (index < 0) return 0;
    return index;
  }

  /// Selected service's tags length
  int get count => tags.length;

  /// Selected service's tags to add length
  int get additionsCount => _tagsToAdd[service]?.length ?? 0;

  /// Selected service's tags to delete length
  int get deletionsCount => _tagsToDelete[service]?.length ?? 0;

  /// If selected service is editable returns true
  bool get editable => isServiceEditable(service);

  void add(Tag tag) => addToService(service, tag);
  void delete(Tag tag) => deleteFromService(service, tag);

  @override
  void onInit() {
    super.onInit();
    ever(selectedService, (_) => sortTags());
  }

  void addToService(String service, Tag tag) {
    if (!isServiceEditable(service)) return;

    final tags = _tags[service]!;
    final tagsToAdd = _tagsToAdd[service]!;
    final tagsToDelete = _tagsToDelete[service]!;

    final existing = tags.firstWhereOrNull((t) => t == tag);
    if (existing != null) {
      if (existing.diff == .delete) {
        existing.diff = null;
        tagsToDelete.remove(existing);
      }
      update();
      return;
    }

    /// If we create new Tag here the ListTile in search won't
    /// change it's color
    final newTag = Tag(tag.raw, count: tag.count, diff: .add);
    tags.insert(0, newTag);
    tagsToAdd.insert(0, newTag);
    update();
  }

  void deleteFromService(String service, Tag tag) {
    if (!isServiceEditable(service)) return;

    final tags = _tags[service]!;
    final tagsToAdd = _tagsToAdd[service]!;
    final tagsToDelete = _tagsToDelete[service]!;

    final target = tags.firstWhereOrNull((t) => t == tag);
    if (target == null) return;

    switch (target.diff) {
      case .delete:
        target.diff = null;
        tagsToDelete.remove(target);
      case .add:
        target.diff = null;
        tags.remove(target);
        tagsToAdd.remove(target);
      case _:
        target.diff = .delete;
        tagsToDelete.addIf(!tagsToDelete.contains(target), target);
    }
    update();
  }
}


extension Init on TagManager {
  void init(Map<String, List<Tag>> servicesMap) {
    final all = Get.find<Repo>().services;

    services
      ..clear()
      ..addAll(all);
    _tags.clear();
    _tagsToAdd.clear();
    _tagsToDelete.clear();

    for (final entry in servicesMap.entries) {
      _tags[entry.key] = entry.value
          .map((tag) => Tag(tag.raw, count: tag.count))
          .toList();
      _tagsToAdd[entry.key] = <Tag>[];
      _tagsToDelete[entry.key] = <Tag>[];
    }

    for (final service in all) {
      _tags.putIfAbsent(service, () => <Tag>[]);
      _tagsToAdd.putIfAbsent(service, () => <Tag>[]);
      _tagsToDelete.putIfAbsent(service, () => <Tag>[]);
    }

    selectedService.value = selectedService.value != ''
        ? selectedService.value
        : services.first;
    update();
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
  Future<void> save(HydrusImage image) async {
    final toAdd = removeEmpty(_tagsToAdd);
    final toRem = removeEmpty(_tagsToDelete);

    final repo = Get.find<Repo>();

    for (final entry in toAdd.entries) {
      var service = entry.key;
      service = await repo.getServiceByName(service);
      final tags = entry.value.map((e) => e.raw).toList();
      await repo.addTags(image.id, service, tags);
    }

    for (final entry in toRem.entries) {
      var service = entry.key;
      service = await repo.getServiceByName(service);
      final tags = entry.value.map((e) => e.raw).toList();
      await repo.removeTags(image.id, service, tags);
    }

    await repo.setMetadataFor(image);
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
}
