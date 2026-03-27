import 'dart:convert';
import 'package:deep_pick/deep_pick.dart';
import 'package:hydrus_flutter/core/logic/entities.dart';


void main() {

}

// MARK: SEARCH RESULTS

List<Tag> parseSearchResults(String query) {
  final json = jsonDecode(query);
  final List<dynamic> tags = json['tags'];
  return tags.take(15).map((e) =>
      Tag(e['value'], count: e['count'])).toList();
}

// MARK: METADATA

void parseMetadataThenWrite(String response, HydrusImage image) {
  final json = jsonDecode(response);
  Pick getMeta(String property) => pick(json, 'metadata', 0, property);

  image.width  = getMeta('width').asDoubleOrThrow();
  image.height = getMeta('height').asDoubleOrThrow();
  image.size = getMeta('size').asIntOrThrow();
  image.mime = getMeta('mime').asStringOrThrow();
  image.duration = getMeta('duration').asIntOrNull() ?? 0;

  final tags = getMeta('tags').asMapOrEmpty<String, dynamic>();
  image.service = _parseTags(tags);
}


Map<String, List<Tag>> _parseTags(Map<String, dynamic> tags) {
  final services = <String, List<Tag>>{};

  tags.forEach((serviceKey, properties) {
    final name = properties['name'];
    final entries = (properties['display_tags']['0'] as List?)?.cast<String>();

    if (entries == null) return;  // <- continue
    services[name as String] = entries.map((s) => Tag(s)).toList();
  });
  return services;
}