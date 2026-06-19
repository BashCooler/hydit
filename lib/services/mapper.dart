import 'dart:convert';

import 'package:deep_pick/deep_pick.dart';

import 'package:hydit/entities/tag.dart';

import '../entities/metadata.dart';
import '../reactive/file.dart';


class Mapper {
  Mapper._();

  static void writeMetadata(String rawJson, HydrusFile image) {
    final json = jsonDecode(rawJson);
    Pick getMeta(String property) => pick(json, 'metadata', 0, property);

    final metadata = FileMetadata(
      width: getMeta('width').asDoubleOrThrow(),
      height: getMeta('height').asDoubleOrThrow(),
      size: getMeta('size').asIntOrThrow(),
      mime: getMeta('mime').asStringOrThrow(),
      duration: getMeta('duration').asIntOrNull() ?? 0,
      combined: getMeta('tags').asMapOrEmpty<String, dynamic>().toTagSet(),
    );

    image.metadata.value = metadata;
  }

  static List<Tag> parseSearchResults(String query) {
    final json = jsonDecode(query);
    final List<dynamic> tags = json['tags'];
    return tags.take(15).map((e) =>
        Tag(e['value'], count: e['count'])).toList();
  }

  static Map<String, String> mapServices(String response) {
    final json = jsonDecode(response);
    final map = <String, String>{};

    pick(json['all_known_tags']).asListOrThrow((pick) {
      final key = pick('service_key').required().asString();
      final name = pick('name').required().asString();
      map[name] = key;
    });

    pick(json['local_tags']).asListOrEmpty((pick) {
      final key = pick('service_key').required().asString();
      final name = pick('name').required().asString();
      map[name] = key;
    });

    pick(json['tag_repositories']).asListOrEmpty((pick) {
      final key = pick('service_key').required().asString();
      final name = pick('name').required().asString();
      map[name] = key;
    });

    return map;
  }
}


extension ParseTags on Map<String, dynamic> {
  Set<Tag> toTagSet() => _parseTags(this);

  static Set<Tag> _parseTags(Map<String, dynamic> tags) {
    final Set<Tag> result = {};

    for (final entry in tags.entries) {
      final service = entry.value;
      final List<dynamic>? entries = service['storage_tags']['0'];
      if (entries == null) continue;
      final serviceTags = entries
          .cast<String>()
          .map((raw) => Tag(raw, service: service['name']));
      result.addAll(serviceTags);
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
