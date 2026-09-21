import 'package:deep_pick/deep_pick.dart';
import 'package:hydit/api/enums.dart';

import 'package:hydit/entities/tag.dart';
import 'package:hydit/entities/service.dart';


class Tags {

  final Map<String, TagService> storage;

  final Map<String, TagService> display;

  final Map<String, List<String>> namespaces;

  Tags(this.storage, this.display, this.namespaces);

  /// The [map] parameter should be extracted from `file_metadata`
  /// response like so:
  ///
  /// `json -> metadata -> 0` (or other index)
  factory Tags.fromMap(Map<String, dynamic> map) {

    final storage = parseTags(map, type: .storage);

    final display = parseTags(map, type: .display);

    final all = display['all known tags']!;

    return Tags(
      storage,
      display,
      buildNamespaceIndex(all),
    );
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

  static Map<String, TagService> parseTags(Map<String, dynamic> metadataEntry, {
    required TagDisplayType type,
  }) {
    final Map<String, TagService> result = {};

    final tagType = type == .storage ? 'storage_tags' : 'display_tags';

    final tags = metadataEntry['tags'] as Map<String, dynamic>;

    for (final MapEntry(:key, value: map) in tags.entries) {

      final storage = pick(map, tagType, '0')
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