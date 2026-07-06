import 'package:get/get.dart';

import 'package:hydit/services/executor.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/entities/service.dart';
import 'package:hydit/reactive/file.dart';

import 'base.dart';


class TagManager extends TagManagerBase {
  final Rx<HydrusFile> file;

  TagManager(HydrusFile file, {String? service}) : file = file.obs {
    init(file, service);
  }

  @override
  int get fileCount => 1;

  @override
  Map<String, TagService> get original => file.value.tags.value;

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
  int count(Tag tag) => 1;

  void init(HydrusFile file, [String? service]) {
    this.file.value = file;

    final tags = file.tags.value
        .map((k, v) => MapEntry(k, v.entries));

    assign(tags);

    if (service != null) {
      this.service.value = service;
    }
  }

  @override
  Future<Result<void>> save() async {
    final result = await repo
        .apply([file.value.id], summarize());

    if (result is Failure) return result;

    return await file.value.update();
  }

  @override
  List<HydrusFile> take([int count = 4]) => [file.value];
}
