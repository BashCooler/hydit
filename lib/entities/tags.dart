import 'package:deep_pick/deep_pick.dart';

import 'package:hydit/api/enums.dart';
import 'package:hydit/utils/utils.dart';
import 'package:hydit/entities/service.dart';


class const Tags(
  final Map<String, TagService> storage,
  final Map<String, TagService> display,
  final Map<String, List<String>> namespaces,
) {
  /// The [map] parameter should be extracted from `file_metadata`
  /// response like so:
  ///
  /// `json -> metadata -> 0` (or other index)
  factory fromMap(Map<String, dynamic> map) {
    final tags = map['tags'] as Map<String, dynamic>;

    final storage = parseTags(tags, type: .storage);
    final display = parseTags(tags, type: .display);

    return Tags(
      storage,
      display,
      display['all known tags']!.let(buildNamespaceIndex),
    );
  }

  /// The [pick] parameter should be extracted from `file_metadata`
  /// response like so:
  ///
  /// `pick(json, 'metadata', 0)` (or other index)
  factory fromPick(Pick pick) =>
      pick.asMapOrThrow<String, dynamic>().let(Tags.fromMap);

  static Map<String, TagService> parseTags(Map<String, dynamic> tags, {
    required TagDisplayType type,
  }) {
    return {
      for (final entry in tags.entries)
        entry.value['name']: TagService.fromMapEntry(entry, type: type),
    };
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
