import 'package:deep_pick/deep_pick.dart';

import 'package:hydit/entities/tag.dart';
import 'package:hydit/entities/service.dart';
import 'package:hydit/utils/collection.dart';


class Tags extends DelegatingMapBase<String, TagService> {

  final Map<String, TagService> tags;
  final Map<String, List<String>> namespaces;

  Tags(this.tags, this.namespaces);

  @override
  Map<String, TagService> get delegate => tags;

  /// The [map] parameter should be extracted from `file_metadata`
  /// response like so:
  ///
  /// `json -> metadata -> 0` (or other index)
  factory Tags.fromMap(Map<String, dynamic> map) {
    final tags = parseTags(map);

    final all = tags['all known tags'];
    final namespaces = buildNamespaceIndex(all!);

    return Tags(tags, namespaces);
  }

  /// The [pick] parameter should be extracted from `file_metadata`
  /// response like so:
  ///
  /// `pick(json, 'metadata', 0)` (or other index)
  factory Tags.fromPick(Pick pick) {
    final map = pick.asMapOrThrow<String, dynamic>();

    return Tags.fromMap(map);
  }

  // MARK: FACTORY METHODS

  static Map<String, TagService> parseTags(Map<String, dynamic> metadataEntry) {
    final Map<String, TagService> result = {};

    final tags = metadataEntry['tags'] as Map<String, dynamic>;

    for (final MapEntry(:key, value: map) in tags.entries) {

      final storage = pick(map, 'storage_tags', '0')
          .asListOrEmpty<String>((t) => t.asStringOrThrow())
          .map(Tag.parse);

      final set = TagSortBuilder(storage)
          .namespace()
          .alphabetical()
          .sort()
          .toSet();

      final name = map['name'];

      final service = TagService(
        name: name,
        key: key,
        type: map['type'],
        initial: set,
      );

      result[name] = service;
    }

    return result;
  }

  static Map<String, List<String>> buildNamespaceIndex(TagService all) {
    final map = <String, List<String>>{};

    for (final tag in all) {
      final ns = tag.namespace;
      if (ns != null) {
        map.putIfAbsent(ns, () => []).add(tag.value);
      }
    }

    for (final values in map.values) {
      values.sort();
    }

    return map;
  }
}