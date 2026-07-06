import 'package:get/get.dart';

import 'package:hydit/entities/service.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/features/editor/getx/base.dart';


class BatchTagManager extends TagManagerBase {
  final _ids = <int>{};
  final _files = <HydrusFile>[];

  @override
  int get fileCount => _ids.length;

  /// Service name -> tag -> count.
  final _counts = <String, Map<Tag, int>>{};

  @override
  Map<String, TagService> get original => _files.first.tags.value;

  @override
  void add(Tag tag) {
    // TODO: implement add
  }

  @override
  void remove(Tag tag) {
    // TODO: implement remove
  }

  @override
  TagState state(Tag tag) {
    // TODO: implement state
    throw UnimplementedError();
  }

  @override
  int count(Tag tag) {
    return _counts[service.value]?[tag] ?? 0;
  }

  void init(Iterable<HydrusFile> files) {
    _ids.assignAll(files.map((f) => f.id));
    _files.assignAll(files);

    final Map<String, Set<Tag>> tags = {};

    _counts.clear();

    for (final file in files) {
      final original = file.tags.value.entries;

      for (final MapEntry(key: name, value: service) in original) {
        tags.putIfAbsent(name, () => {}).addAll(service.entries);

        final serviceCounts = _counts.putIfAbsent(name, () => {});

        for (final tag in service.entries) {
          serviceCounts[tag] = (serviceCounts[tag] ?? 0) + 1;
        }
      }
    }

    assign(tags);
  }

  @override
  List<HydrusFile> take([int count = 4]) {
    return _files.take(count).toList();
  }
}