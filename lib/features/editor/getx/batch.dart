import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:hydit/entities/service.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/features/editor/getx/base.dart';
import 'package:hydit/services/executor.dart';
import 'package:hydit/utils/utils.dart';


class BatchTagManager extends TagManagerBase {
  final List<HydrusFile> files;

  BatchTagManager(this.files) {
    init();
  }

  final _added = <String, RxSet<Tag>>{};
  Set<Tag> get added => _added[service.value]!;

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

    final state = this.state(tag);
    final count = this.count(tag);

    if (count == files.length) {

      switch (state) {
        case .removed:
          current.add(tag);
        case _:
          current.remove(tag);
      }

      return;
    }

    switch (state) {
      case .removed:
        current.add(tag);
      case .unchanged:
        Get.dialog(
          transitionDuration: 150.ms,
          AlertDialog(
            icon: const Icon(Symbols.arrow_split),
            actionsAlignment: .center,
            title: const Text('Add or delete tag?'),
            actions: [
              TextButton(
                onPressed: () => added.add(tag),
                child: const Text('Add'),
              ),
              TextButton(
                onPressed: () => current.remove(tag),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      case .added when initial.contains(tag):
        added.remove(tag);
      case .added:
        current.remove(tag);
    }
  }

  @override
  TagState state(Tag tag) {
    final inO = initial.contains(tag);
    final inC = current.contains(tag);

    if (inO && inC) {
      if (added.contains(tag)) {
        return .added;
      }

      return .unchanged;
    }
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
        _added.putIfAbsent(name, () => <Tag>{}.obs);

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
  bool get unlocked =>
      super.unlocked && _added.values.expand((s) => s).isEmpty;

  @override
  Future<Result<void>> save() async {
    final result = await repo
        .apply(files.map((f) => f.id), summarize());

    if (result is Failure) return result;

    return repo.update(files);
  }

  @override
  List<TagDiff> summarize() {
    final changes = super.summarize();

    for (final MapEntry(key: name, value: tagsToAdd) in _added.entries) {
      if (tagsToAdd.isEmpty) continue;

      final change = TagDiff(
        key: original[name]!.key,
        added: tagsToAdd,
        deleted: {},
      );

      changes.add(change);
    }

    return changes;
  }

  @override
  ({int add, int del}) diff([String? service]) {
    final diff = super.diff(service);

    final add = _added[service ?? this.service.value]!;

    return (add: diff.add + add.length, del: diff.del);
  }
}
