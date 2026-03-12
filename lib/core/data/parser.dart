import 'dart:convert';
import 'package:deep_pick/deep_pick.dart';
import 'package:hydrus_flutter/core/logic/entities.dart';


void main() {
  // final String response = '{"metadata": [{"file_id": 170344670, "hash": "1ef668e74fd54e5dc6933e6e28a9a233a6552c6522c8930c8cd6286edace0f7b", "size": 1363482, "mime": "image/png", "filetype_human": "png", "filetype_enum": 2, "ext": ".png", "width": 1540, "height": 1964, "duration": null, "num_frames": null, "num_words": null, "has_audio": false, "blurhash": "U68zP.t70K9ZxaR*NGxt9tkCs:s:9Zj[?HRk", "pixel_hash": "907cd353f73d31c5dd0a35b44db8ff8f4e9cebb1062dba630820ca9f41898101", "filetype_forced": false, "thumbnail_width": 362, "thumbnail_height": 462, "file_services": {"current": {"616c6c206c6f63616c2066696c6573": {"name": "all local files", "type": 15, "type_pretty": "virtual combined local file service", "time_imported": 1758224065}, "616c6c206c6f63616c206d65646961": {"name": "all my files", "type": 21, "type_pretty": "virtual combined local media service", "time_imported": 1758224065}, "6c6f63616c2066696c6573": {"name": "my files", "type": 2, "type_pretty": "local file domain", "time_imported": 1758224065}}, "deleted": {}}, "time_modified": 1672149483, "time_modified_details": {"i.pximg.net": 1672149483, "local": 1688191102}, "is_inbox": false, "is_local": true, "is_trashed": false, "is_deleted": false, "has_transparency": false, "has_exif": false, "has_human_readable_embedded_metadata": true, "has_icc_profile": false, "known_urls": ["https://i.pximg.net/img-original/img/2022/12/27/22/58/03/103973048_p2.png", "https://www.pixiv.net/en/artworks/103973048"], "ipfs_multihashes": {}, "ratings": {"6661766f757269746573": null}, "tags": {"a6b99cec4194c950847fe2569f91bb58da65db89f5d545334971f3deefb11b58": {"name": "ai", "type": 5, "type_pretty": "local tag service", "storage_tags": {}, "display_tags": {}}, "616c6c206b6e6f776e2074616773": {"name": "all known tags", "type": 10, "type_pretty": "virtual combined tag service", "storage_tags": {"0": ["creator:oishiinasubi", "creator:\u3088\u3057\u304a\u304b", "local source:g", "needy girl overdose 100+ bookmarks", "needy_girl_overdose", "needy_girl_overdose100users\u5165\u308a", "page:3", "pixiv work:103973048", "r-18g", "title:#needy_pic"]}, "display_tags": {"0": ["creator:oishiinasubi", "creator:\u3088\u3057\u304a\u304b", "local source:g", "needy girl overdose 100+ bookmarks", "needy_girl_overdose", "needy_girl_overdose100users\u5165\u308a", "page:3", "pixiv work:103973048", "r-18g", "title:#needy_pic"]}}, "646f776e6c6f616465722074616773": {"name": "downloader tags", "type": 5, "type_pretty": "local tag service", "storage_tags": {"0": ["creator:oishiinasubi", "creator:\u3088\u3057\u304a\u304b", "needy girl overdose 100+ bookmarks", "needy_girl_overdose", "needy_girl_overdose100users\u5165\u308a", "page:3", "r-18g", "title:#needy_pic"]}, "display_tags": {"0": ["creator:oishiinasubi", "creator:\u3088\u3057\u304a\u304b", "needy girl overdose 100+ bookmarks", "needy_girl_overdose", "needy_girl_overdose100users\u5165\u308a", "page:3", "r-18g", "title:#needy_pic"]}}, "6c6f63616c2074616773": {"name": "my tags", "type": 5, "type_pretty": "local tag service", "storage_tags": {"0": ["local source:g", "pixiv work:103973048"]}, "display_tags": {"0": ["local source:g", "pixiv work:103973048"]}}, "d6a661d0c1d682fbfe6eae5b555234780699cc841ef288049036b76eb4f7ff31": {"name": "public tag repository", "type": 0, "type_pretty": "hydrus tag repository", "storage_tags": {}, "display_tags": {}}}, "file_viewing_statistics": [{"canvas_type": 0, "canvas_type_pretty": "media viewer", "views": 2, "viewtime": 7.442, "last_viewed_timestamp": 1770321674.092}, {"canvas_type": 1, "canvas_type_pretty": "preview viewer", "views": 4, "viewtime": 113.31, "last_viewed_timestamp": 1770324353.88}, {"canvas_type": 4, "canvas_type_pretty": "client api viewer", "views": 0, "viewtime": 0.0, "last_viewed_timestamp": null}]}], "services": {"a6b99cec4194c950847fe2569f91bb58da65db89f5d545334971f3deefb11b58": {"name": "ai", "type": 5, "type_pretty": "local tag service"}, "646f776e6c6f616465722074616773": {"name": "downloader tags", "type": 5, "type_pretty": "local tag service"}, "6c6f63616c2074616773": {"name": "my tags", "type": 5, "type_pretty": "local tag service"}, "d6a661d0c1d682fbfe6eae5b555234780699cc841ef288049036b76eb4f7ff31": {"name": "public tag repository", "type": 0, "type_pretty": "hydrus tag repository"}, "6c6f63616c2066696c6573": {"name": "my files", "type": 2, "type_pretty": "local file domain"}, "7265706f7369746f72792075706461746573": {"name": "repository updates", "type": 20, "type_pretty": "local update file domain"}, "616c6c206c6f63616c2066696c6573": {"name": "all local files", "type": 15, "type_pretty": "virtual combined local file service"}, "616c6c206c6f63616c206d65646961": {"name": "all my files", "type": 21, "type_pretty": "virtual combined local media service"}, "616c6c206b6e6f776e2066696c6573": {"name": "all known files", "type": 11, "type_pretty": "virtual combined file service"}, "616c6c206b6e6f776e2074616773": {"name": "all known tags", "type": 10, "type_pretty": "virtual combined tag service"}, "6661766f757269746573": {"name": "favourites", "type": 7, "type_pretty": "local like/dislike rating service", "star_shape": "fat star"}, "7472617368": {"name": "trash", "type": 14, "type_pretty": "local trash file domain"}}, "version": 81, "hydrus_version": 645}';
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
  Pick _pick(String property) => pick(json, 'metadata', 0, property);

  final int width  = _pick('width').asIntOrThrow();
  final int height = _pick('height').asIntOrThrow();
  final String mime = _pick('mime').asStringOrThrow();
  final int duration = _pick('duration').asIntOrNull() ?? 0;

  final tags = _pick('tags').asMapOrEmpty<String, dynamic>();
  final Map<String, TagService> service = _parseTags(tags);

  image.width = width;
  image.height = height;
  image.mime = mime;
  image.duration = duration;
  image.service = service;
}


Map<String, TagService> _parseTags(Map<String, dynamic> tags) {
  final services = <String, TagService>{};
  tags.forEach((k, v) {
    final entries = (v['display_tags']['0'] as List?)?.cast<String>();
    if (entries == null) return;  // <- continue
    final name = v['name'];
    services[name as String] = TagService(
      service: k,
      entries: entries.map((s) => Tag(s)).toList(),
    );
  });
  return services;
}