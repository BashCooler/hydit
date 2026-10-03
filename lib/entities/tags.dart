import 'package:deep_pick/deep_pick.dart';
import 'package:hydit/entities/tag.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/entities/service.dart';


class const Tags({
  required final Map<String, TagService> _tags,
  required final Map<String, List<String>> namespaces,
}) extends DelegatingMapBase<String, TagService> {

  @override
  Map<String, TagService> get delegate => _tags;

  /// Display tags from `all known tags` service.
  Iterable<Tag> get all => _tags['all known tags']!.display;

  /// The [map] parameter should be extracted from `file_metadata`
  /// response like so:
  ///
  /// `json -> metadata -> 0` (or other index)
  factory fromMap(Map<String, dynamic> map) {
    final tags = pick(map, 'tags').asMapOrThrow<String, dynamic>() //
        .let(parseTags);

    return Tags(
      tags: tags,
      namespaces: tags['all known tags']!.namespaces(),
    );
  }

  /// The [pick] parameter should be extracted from `file_metadata`
  /// response like so:
  ///
  /// `pick(json, 'metadata', 0)` (or other index)
  factory fromPick(Pick pick) =>
      pick.asMapOrThrow<String, dynamic>().let(Tags.fromMap);

  static Map<String, TagService> parseTags(Map<String, dynamic> tags) {
    return {
      for (final entry in tags.entries)
        entry.value['name']: TagService.fromMapEntry(entry),
    };
  }
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
