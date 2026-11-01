import 'package:hydit/api/models.dart';
import 'package:hydit/entities/tag.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/features/viewer/getx/page.dart';

import 'base.dart';


class PagedTagManager({
  required final PageGetxController page,
  String? service,
}) extends TagManager {

  this {
    init();
    this.service = service;
  }

  HydrusFile get file => page.current;

  @override
  List<HydrusFile> get files => [file];

  @override
  Map<String, TagService> get original => file.tags;

  @override
  Map<String, Set<Tag>> get initTags =>
      file.tags.map((k, v) => MapEntry(k, v.storage));

  @override
  int count(Tag tag) => 1;
}
