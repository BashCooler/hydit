import 'package:collection/collection.dart';

import 'package:hydit/api/models.dart';
import 'package:hydit/entities/tag.dart';


class const Tags({
  required final Map<String, TagService> _tags,
  required final Map<String, List<String>> namespaces,
}) extends DelegatingMap<String, TagService> {

  this : super(_tags);

  /// Display tags from `all known tags` service.
  TagService get all => _tags.all;

  factory fromDto(FileMetadataDto dto) => Tags(
    tags: dto.tags,
    namespaces: dto.tags.all.namespaces(),
  );
}


extension BuildNamespaceIndex on TagService {
  /// Builds the namespace index for this service.
  Map<String, List<String>> namespaces() {
    final map = <String, List<String>>{};

    for (var Tag(namespace: ns, value: v) in display) {
      if (ns != null) map.putIfAbsent(ns, () => []).add(v);
    }

    return map
      ..values.forEach((v) => v.sort());
  }
}
