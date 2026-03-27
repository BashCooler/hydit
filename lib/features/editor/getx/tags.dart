import 'package:get/get.dart';
import 'package:hydrus_flutter/core/logic/entities.dart';


class TagManager extends GetxController {
  static const readOnlyServices = [
    'all known tags',
    'public tag repository',
  ];

  final services = <String>[].obs;
  final selectedService = ''.obs;

  final Map<String, RxList<Tag>> _tags = {};
  final Map<String, RxList<Tag>> _tagsToAdd = {};
  final Map<String, RxList<Tag>> _tagsToDelete = {};

  String get activeService => selectedService.value;

  int get activeIndex {
    if (services.isEmpty) return 0;
    final index = services.indexOf(selectedService.value);
    if (index < 0) return 0;
    return index;
  }

  RxList<Tag> get activeTags => _tags[selectedService.value]!;

  int get serviceAdditions => _tagsToAdd[selectedService.value]!.length;
  int get serviceDeletions => _tagsToDelete[selectedService.value]!.length;
  int get tagCount => activeTags.length;

  bool get activeServiceEditable => isServiceEditable(selectedService.value);
  bool isServiceEditable(String service) => !readOnlyServices.contains(service);

  void init(Map<String, List<Tag>> servicesMap) {
    services
      ..clear()
      ..addAll(servicesMap.keys);
    _tags.clear();
    _tagsToAdd.clear();
    _tagsToDelete.clear();

    for (final entry in servicesMap.entries) {
      _tags[entry.key] = entry.value
          .map((tag) => Tag(tag.raw, count: tag.count))
          .toList()
          .obs;
      _tagsToAdd[entry.key] = <Tag>[].obs;
      _tagsToDelete[entry.key] = <Tag>[].obs;
    }

    selectedService.value = services.isNotEmpty ? services.first : '';
    update();
  }

  void selectServiceByIndex(int index) {
    if (index < 0 || index >= services.length) return;
    selectedService.value = services[index];
    update();
  }

  void add(Tag tag) => addToService(selectedService.value, tag);
  void delete(Tag tag) => deleteFromService(selectedService.value, tag);

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

  String pretty(String service) => switch (service) {
    'all known tags' => 'All',
    'public tag repository' => 'PTR',
    _ => service,
  };
}
