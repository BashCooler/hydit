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

  @override
  List<HydrusFile> get files => [page.current];

  HydrusFile get file => page.current;

  @override
  Map<String, TagService> get original => file.tags;

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

    final tags = file.tags.map((k, v) => MapEntry(k, v.storage));

    assign(tags);

    this.service = service;
  }
}
