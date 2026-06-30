import 'dart:collection';

import 'package:deep_pick/deep_pick.dart';

import 'package:hydit/entities/tag.dart';
import 'package:hydit/entities/service.dart';


class Tags extends MapBase<String, TagService> {
  final Map<String, TagService> tags;
  final Map<String, List<String>> namespaces;

  Tags(this.tags, this.namespaces);

  factory Tags.fromMap(Map<String, dynamic> metadataEntry) {
    final tags = parseTags(metadataEntry);

    final all = tags['all known tags'];
    final namespaces = buildNamespaceIndex(all!);

    return Tags(tags, namespaces);
  }

  /// Replace all elements of this map with key/value
  /// pairs from [other].
  void assignAll(Map<String, TagService> other) {
    tags.clear();
    tags.addAll(other);
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

    for (final tag in all.entries) {
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

  // MARK: OVERRIDES

  @override
  TagService? operator [](Object? key) => tags[key];

  @override
  void operator []=(String key, TagService value) => tags[key] = value;

  @override
  void clear() => tags.clear();

  @override
  Iterable<String> get keys => tags.keys;

  @override
  TagService? remove(Object? key) => tags.remove(key);
}