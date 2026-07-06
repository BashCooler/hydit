import 'package:hydit/entities/service.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/features/editor/getx/base.dart';
import 'package:hydit/services/executor.dart';


class BatchTagManager extends TagManagerBase {
  final List<HydrusFile> files;

  BatchTagManager(this.files) {
    init();
  }

  @override
  int get fileCount => files.length;

  /// Service name -> tag -> count.
  final _counts = <String, Map<Tag, int>>{};

  @override
  Map<String, TagService> get original => files.first.tags.value;

  @override
  void add(Tag tag) {
    if (!editable) return;
    if (tag.raw.isEmpty) return;
    current.add(tag);
  }

  @override
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

  @override
  TagState state(Tag tag) {
    final inO = initial.contains(tag);
    final inC = current.contains(tag);

    if (inO && inC) return .unchanged;
    if (!inO && inC) return .added;
    return .removed;
  }

  @override
  int count(Tag tag) {
    return _counts[service.value]?[tag] ?? 0;
  }

  void init() {
    final Map<String, Set<Tag>> tags = {};

    for (final file in files) {
      final original = file.tags.value.entries;

      for (final MapEntry(key: name, value: service) in original) {
        tags.putIfAbsent(name, () => {}).addAll(service.entries);

        countService(name, service);
      }
    }

    assign(tags);
  }

  void countService(String name, TagService service) {
    final serviceCounts = _counts.putIfAbsent(name, () => {});

    for (final tag in service.entries) {
      serviceCounts[tag] = (serviceCounts[tag] ?? 0) + 1;
    }
  }

  @override
  List<HydrusFile> take([int count = 4]) {
    return files.take(count).toList();
  }

  @override
  Future<Result<void>> save() async {
    final result = await repo
        .apply(files.map((f) => f.id), summarize());

    if (result is Failure) return result;

    return repo.update(files);
  }
}
