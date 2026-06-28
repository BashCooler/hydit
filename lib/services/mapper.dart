import 'dart:convert';

import 'package:deep_pick/deep_pick.dart';
import 'package:hydit/api/models/service.dart';

import 'package:hydit/entities/tag.dart';

import '../entities/metadata.dart';
import '../reactive/file.dart';


class Mapper {
  Mapper._();

  static void writeMetadata(String rawJson, HydrusFile image) {
    final json = jsonDecode(rawJson);
    Pick meta = pick(json, 'metadata', 0);

    final metadata = FileMetadata(
      width: meta('width').asDoubleOrNull() ?? 0,
      height: meta('height').asDoubleOrNull() ?? 0,
      size: meta('size').asIntOrThrow(),
      mime: meta('mime').asStringOrThrow(),
      duration: meta('duration').asIntOrNull() ?? 0,
      combined: meta('tags').asMapOrThrow<String, dynamic>().parseTags(),
    );

    image.metadata.value = metadata;
  }

  static List<Tag> parseSearchResults(String query) {
    final json = jsonDecode(query);
    final List<dynamic> tags = json['tags'];
    return tags.take(15).map((e) =>
        Tag(e['value'], count: e['count'])).toList();
  }

  static List<TagService> mapServices(String response) {
    final json = jsonDecode(response) as Map<String, dynamic>;

    final all = pick(json, 'all_known_tags', 0)
        .asMapOrThrow<String, dynamic>();

    final local = pick(json, 'local_tags')
        .asListOrEmpty((pick) => pick.asMapOrThrow<String, dynamic>());

    final repositories = pick(json, 'tag_repositories')
        .asListOrEmpty((pick) => pick.asMapOrThrow<String, dynamic>());

    return [
      TagService.fromMap(all),
      ...local.map((map) => .fromMap(map, editable: true)),
      ...repositories.map((map) => .fromMap(map)),
    ];
  }
}


extension ParseTags on Map<String, dynamic> {
  Map<String, Set<Tag>> parseTags() => _parseTags(this);

  static Map<String, Set<Tag>> _parseTags(Map<String, dynamic> tags) {
    final Map<String, Set<Tag>> result = {};

    for (final entry in tags.values) {
      final service = entry as Map<String, dynamic>;

      final name = service['name'];
      final storage = pick(service, 'storage_tags', '0')
          .asListOrEmpty<String>((t) => t.asStringOrThrow())
          .map((t) => Tag(t));

      result[name] = TagSortBuilder(storage)
          .namespace()
          .alphabetical()
          .sort()
          .toSet();
    }

    return result;
  }
}


extension Parsers on String {

  Pick pick([
    Object? arg0,
    Object? arg1,
    Object? arg2,
    Object? arg3,
    Object? arg4,
    Object? arg5,
    Object? arg6,
    Object? arg7,
    Object? arg8,
    Object? arg9,
  ]) {
    return pickDeep(this, [
      ?arg0,
      ?arg1,
      ?arg2,
      ?arg3,
      ?arg4,
      ?arg5,
      ?arg6,
      ?arg7,
      ?arg8,
      ?arg9,
    ]);
  }

  dynamic decode() => jsonDecode(this);
}


extension AssignAll<K, V> on Map<K, V> {
  void assignAll(Map<K, V> map) => this..clear()..addAll(map);
}
