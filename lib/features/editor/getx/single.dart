import 'package:hydit/services/executor/executor.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/entities/service.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/features/viewer/getx/page.dart';

import 'base.dart';


class PagedTagManager extends TagManager {
  final PageGetxController page;

  PagedTagManager({required this.page, String? service}) {
    init(service);
  }

  HydrusFile get file => page.current;

  @override
  int get fileCount => 1;

  @override
  Map<String, TagService> get original => file.tags.value;

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
  int count(Tag tag) => 1;

  void init([String? service]) {

    final tags = file.tags.value
        .map((k, v) => MapEntry(k, v.entries));

    assign(tags);

    this.service = service ?? 'my tags';
  }

  @override
  Future<Result<void>> save() async {
    final result = await repo
        .apply([file.id], summarize());

    if (result is Failure) return result;

    return await file.update();
  }

  @override
  List<HydrusFile> take([int count = 4]) => [file];
}
