import 'dart:convert';

import 'package:deep_pick/deep_pick.dart';

import 'package:hydit/entities/tag.dart';
import 'package:hydit/reactive/service.dart';

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
      combined: {}, // TODO remove this field
    );

    image.metadata.value = metadata;

    final tags = meta('tags').asMapOrThrow<String, dynamic>();
    image.tags.value = parseTags(tags);
  }

  static List<Tag> parseSearchResults(String query) {
    final json = jsonDecode(query);
    final List<dynamic> tags = json['tags'];
    return tags.take(15).map((e) =>
        Tag(e['value'], count: e['count'])).toList();
  }

  static Map<String, TagService> parseTags(Map<String, dynamic> tags) {
    final Map<String, TagService> result = {};

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
}


extension ParseTags on Map<String, dynamic> {
  Map<String, TagService> parseTags() => Mapper.parseTags(this);
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
