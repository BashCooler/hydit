import 'dart:convert';
import 'package:deep_pick/deep_pick.dart';
import 'package:hydit/core/domain/entities.dart';


class Mapper {
  static Future<void> writeMetadata(String rawJson, HydrusFile image) async {
    final json = jsonDecode(rawJson);
    Pick getMeta(String property) => pick(json, 'metadata', 0, property);

    image.width  = getMeta('width').asDoubleOrThrow();
    image.height = getMeta('height').asDoubleOrThrow();
    image.size = getMeta('size').asIntOrThrow();
    image.mime = getMeta('mime').asStringOrThrow();
    image.duration = getMeta('duration').asIntOrNull() ?? 0;

    final tags = getMeta('tags').asMapOrEmpty<String, dynamic>();
    image.combined..clear()..addAll(_parseTags(tags));
  }

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

  static List<Tag> parseSearchResults(String query) {
    final json = jsonDecode(query);
    final List<dynamic> tags = json['tags'];
    return tags.take(15).map((e) =>
        Tag(e['value'], count: e['count'])).toList();
  }
}