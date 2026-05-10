import 'dart:convert';
import 'package:deep_pick/deep_pick.dart';
import 'package:hydrus_flutter/core/domain/entities.dart';


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
    image.service..clear()..addAll(_parseTags(tags));
  }

  static Map<String, List<Tag>> _parseTags(Map<String, dynamic> tags) {
    final services = <String, List<Tag>>{};

    tags.forEach((serviceKey, properties) {
      final name = properties['name'];
      final entries = (properties['storage_tags']['0'] as List?)?.cast<String>();

      if (entries == null) return;  // <- continue
      services[name as String] = entries.map((s) => Tag(s)).toList();
    });
    return services;
  }

  static List<Tag> parseSearchResults(String query) {
    final json = jsonDecode(query);
    final List<dynamic> tags = json['tags'];
    return tags.take(15).map((e) =>
        Tag(e['value'], count: e['count'])).toList();
  }
}