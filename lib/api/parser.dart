import 'dart:convert';
import 'dart:io';

import 'hydrus.dart';


void main() async {
  // String response = '{"metadata": [{"file_id": 170345180, "hash": "3155f7f554be8ad8d4edde5cbf0efa95e4230dc64186b628f8e82221c031a408", "size": 1010879, "mime": "image/jpeg", "filetype_human": "jpeg", "filetype_enum": 1, "ext": ".jpg", "width": 2480, "height": 3508, "duration": null, "num_frames": null, "num_words": null, "has_audio": false, "blurhash": "cvOg4.RQ_NxuWBWBIoayn%?bofWVt7ofRj", "pixel_hash": "87621f8e673d1402e567f13b6bf83f6dd4177d357b6d60e2290120324f4f9917", "filetype_forced": false, "thumbnail_width": 326, "thumbnail_height": 462, "file_services": {"current": {"616c6c206c6f63616c2066696c6573": {"name": "all local files", "type": 15, "type_pretty": "virtual combined local file service", "time_imported": 1758224317}, "616c6c206c6f63616c206d65646961": {"name": "all my files", "type": 21, "type_pretty": "virtual combined local media service", "time_imported": 1758224317}, "6c6f63616c2066696c6573": {"name": "my files", "type": 2, "type_pretty": "local file domain", "time_imported": 1758224317}}, "deleted": {}}, "time_modified": 1708177738, "time_modified_details": {"local": 1708177738}, "is_inbox": true, "is_local": true, "is_trashed": false, "is_deleted": false, "has_transparency": false, "has_exif": false, "has_human_readable_embedded_metadata": true, "has_icc_profile": false, "known_urls": [], "ipfs_multihashes": {}, "ratings": {"6661766f757269746573": null}, "tags": {"a6b99cec4194c950847fe2569f91bb58da65db89f5d545334971f3deefb11b58": {"name": "ai", "type": 5, "type_pretty": "local tag service", "storage_tags": {}, "display_tags": {}}, "616c6c206b6e6f776e2074616773": {"name": "all known tags", "type": 10, "type_pretty": "virtual combined tag service", "storage_tags": {"0": ["local source:g", "pixiv work:109427049"]}, "display_tags": {"0": ["local source:g", "pixiv work:109427049"]}}, "646f776e6c6f616465722074616773": {"name": "downloader tags", "type": 5, "type_pretty": "local tag service", "storage_tags": {}, "display_tags": {}}, "6c6f63616c2074616773": {"name": "my tags", "type": 5, "type_pretty": "local tag service", "storage_tags": {"0": ["local source:g", "pixiv work:109427049"]}, "display_tags": {"0": ["local source:g", "pixiv work:109427049"]}}, "d6a661d0c1d682fbfe6eae5b555234780699cc841ef288049036b76eb4f7ff31": {"name": "public tag repository", "type": 0, "type_pretty": "hydrus tag repository", "storage_tags": {}, "display_tags": {}}}, "file_viewing_statistics": [{"canvas_type": 0, "canvas_type_pretty": "media viewer", "views": 0, "viewtime": 0.0, "last_viewed_timestamp": null}, {"canvas_type": 1, "canvas_type_pretty": "preview viewer", "views": 0, "viewtime": 0.0, "last_viewed_timestamp": null}, {"canvas_type": 4, "canvas_type_pretty": "client api viewer", "views": 0, "viewtime": 0.0, "last_viewed_timestamp": null}]}, {"file_id": 170345178, "hash": "fcb895cad8b15ca1e59a78000bea4bd9f35949ecf401414701fe13817357c92e", "size": 1132359, "mime": "image/jpeg", "filetype_human": "jpeg", "filetype_enum": 1, "ext": ".jpg", "width": 2480, "height": 3508, "duration": null, "num_frames": null, "num_words": null, "has_audio": false, "blurhash": "cxODUuM{_Nx]bHV@Ioaynj?HoebHxuozNG", "pixel_hash": "0fa750119c6d3508cb58b819c867719327129cf5141360a2d91d604ff1c5046f", "filetype_forced": false, "thumbnail_width": 326, "thumbnail_height": 462, "file_services": {"current": {"616c6c206c6f63616c2066696c6573": {"name": "all local files", "type": 15, "type_pretty": "virtual combined local file service", "time_imported": 1758224316}, "616c6c206c6f63616c206d65646961": {"name": "all my files", "type": 21, "type_pretty": "virtual combined local media service", "time_imported": 1758224316}, "6c6f63616c2066696c6573": {"name": "my files", "type": 2, "type_pretty": "local file domain", "time_imported": 1758224316}}, "deleted": {}}, "time_modified": 1708177738, "time_modified_details": {"local": 1708177738}, "is_inbox": true, "is_local": true, "is_trashed": false, "is_deleted": false, "has_transparency": false, "has_exif": false, "has_human_readable_embedded_metadata": true, "has_icc_profile": false, "known_urls": [], "ipfs_multihashes": {}, "ratings": {"6661766f757269746573": null}, "tags": {"a6b99cec4194c950847fe2569f91bb58da65db89f5d545334971f3deefb11b58": {"name": "ai", "type": 5, "type_pretty": "local tag service", "storage_tags": {}, "display_tags": {}}, "616c6c206b6e6f776e2074616773": {"name": "all known tags", "type": 10, "type_pretty": "virtual combined tag service", "storage_tags": {"0": ["local source:g", "pixiv work:109427049"]}, "display_tags": {"0": ["local source:g", "pixiv work:109427049"]}}, "646f776e6c6f616465722074616773": {"name": "downloader tags", "type": 5, "type_pretty": "local tag service", "storage_tags": {}, "display_tags": {}}, "6c6f63616c2074616773": {"name": "my tags", "type": 5, "type_pretty": "local tag service", "storage_tags": {"0": ["local source:g", "pixiv work:109427049"]}, "display_tags": {"0": ["local source:g", "pixiv work:109427049"]}}, "d6a661d0c1d682fbfe6eae5b555234780699cc841ef288049036b76eb4f7ff31": {"name": "public tag repository", "type": 0, "type_pretty": "hydrus tag repository", "storage_tags": {}, "display_tags": {}}}, "file_viewing_statistics": [{"canvas_type": 0, "canvas_type_pretty": "media viewer", "views": 0, "viewtime": 0.0, "last_viewed_timestamp": null}, {"canvas_type": 1, "canvas_type_pretty": "preview viewer", "views": 0, "viewtime": 0.0, "last_viewed_timestamp": null}, {"canvas_type": 4, "canvas_type_pretty": "client api viewer", "views": 0, "viewtime": 0.0, "last_viewed_timestamp": null}]}, {"file_id": 170345176, "hash": "d1d2a195db77f6cac8618015639345cb20d6ff51a0481f06566e616cc8aaa8ef", "size": 2685454, "mime": "image/jpeg", "filetype_human": "jpeg", "filetype_enum": 1, "ext": ".jpg", "width": 2480, "height": 3508, "duration": null, "num_frames": null, "num_words": null, "has_audio": false, "blurhash": "cLH1r,i{D.?dI;s;56o}-:-WsCS5-rR*M{", "pixel_hash": "aaaa2d404a941d834388bf58c9f1683aced7af88378cf3cb84d53719a104f039", "filetype_forced": false, "thumbnail_width": 326, "thumbnail_height": 462, "file_services": {"current": {"616c6c206c6f63616c2066696c6573": {"name": "all local files", "type": 15, "type_pretty": "virtual combined local file service", "time_imported": 1758224316}, "616c6c206c6f63616c206d65646961": {"name": "all my files", "type": 21, "type_pretty": "virtual combined local media service", "time_imported": 1758224316}, "6c6f63616c2066696c6573": {"name": "my files", "type": 2, "type_pretty": "local file domain", "time_imported": 1758224316}}, "deleted": {}}, "time_modified": 1701634684, "time_modified_details": {"local": 1701634684}, "is_inbox": true, "is_local": true, "is_trashed": false, "is_deleted": false, "has_transparency": false, "has_exif": false, "has_human_readable_embedded_metadata": true, "has_icc_profile": false, "known_urls": [], "ipfs_multihashes": {}, "ratings": {"6661766f757269746573": null}, "tags": {"a6b99cec4194c950847fe2569f91bb58da65db89f5d545334971f3deefb11b58": {"name": "ai", "type": 5, "type_pretty": "local tag service", "storage_tags": {}, "display_tags": {}}, "616c6c206b6e6f776e2074616773": {"name": "all known tags", "type": 10, "type_pretty": "virtual combined tag service", "storage_tags": {"0": ["local source:g", "pixiv work:109427049"]}, "display_tags": {"0": ["local source:g", "pixiv work:109427049"]}}, "646f776e6c6f616465722074616773": {"name": "downloader tags", "type": 5, "type_pretty": "local tag service", "storage_tags": {}, "display_tags": {}}, "6c6f63616c2074616773": {"name": "my tags", "type": 5, "type_pretty": "local tag service", "storage_tags": {"0": ["local source:g", "pixiv work:109427049"]}, "display_tags": {"0": ["local source:g", "pixiv work:109427049"]}}, "d6a661d0c1d682fbfe6eae5b555234780699cc841ef288049036b76eb4f7ff31": {"name": "public tag repository", "type": 0, "type_pretty": "hydrus tag repository", "storage_tags": {}, "display_tags": {}}}, "file_viewing_statistics": [{"canvas_type": 0, "canvas_type_pretty": "media viewer", "views": 0, "viewtime": 0.0, "last_viewed_timestamp": null}, {"canvas_type": 1, "canvas_type_pretty": "preview viewer", "views": 0, "viewtime": 0.0, "last_viewed_timestamp": null}, {"canvas_type": 4, "canvas_type_pretty": "client api viewer", "views": 0, "viewtime": 0.0, "last_viewed_timestamp": null}]}], "version": 81, "hydrus_version": 645}';
  // print(parseMetadata(response));
  Client client = Client(accessKey: '86106807bd3cfe58cd0c5664981799dbaf978454a91b26afd3c5a60e3ad2c813');
  String response = await client.getSearchTags('shi', tagDisplayType: 'storage');
  print(parseSearchResults(response).toString());
  exit(0);
}

// MARK: METADATA

List<Map<String, dynamic>> parseMetadata(String data) {
  Map<String, dynamic> parsedJson = jsonDecode(data);
  var unwrappedJson = UnwrappedJson.fromJson(parsedJson).metadata;  // type: List of Maps

  /// Parse each item
  List<Map<String, dynamic>> params = [];
  for (var item in unwrappedJson) {
    params.add(_parseItem(item));
  }

  return params;
}

Map<String, dynamic> _parseItem(Map<String, dynamic> unwrappedJson) {
  FileMetadata metadata = FileMetadata.fromJson(unwrappedJson);

  /// Remember primitive typed data
  final fileId = metadata.fileId;
  final width  = metadata.width;
  final height = metadata.height;
  final mime = metadata.mime;
  final duration = metadata.duration;

  /// Unwrap tags
  // List<dynamic> services = List.from(metadata.tags.values);

  /// Parse each service
  /// TODO parse tags from services

  return {
    'file_id': fileId,
    'width': width,
    'height': height,
    'mime': mime,
    'duration': duration,
  };
}

class UnwrappedJson {
  final List<dynamic> metadata;

  UnwrappedJson(this.metadata);

  /// Step inside <s>see the devil in I</s> JSON and return
  /// a [List], each item of the [List] contains metadata for a
  /// single file
  factory UnwrappedJson.fromJson(Map<String, dynamic> parsedJson) {
    List<dynamic> metadataList = parsedJson['metadata'];
    return UnwrappedJson(metadataList);
  }
}

class FileMetadata {
  final int fileId, width, height;
  final String mime;
  final int duration;
  final Map<String, dynamic> tags;

  FileMetadata(this.fileId, this.width, this.height, this.mime, this.duration, this.tags);

  /// Extract parameters from unwrapped JSON.<br>
  /// [tags] is a Map and should be unwrapped further.
  factory FileMetadata.fromJson(Map<String, dynamic> fileMetadata) {
    final fileId = fileMetadata['file_id'];
    final width  = fileMetadata['width'];
    final height = fileMetadata['height'];
    final mime = fileMetadata['mime'];
    final duration = fileMetadata['duration'] ?? 0;  /// YOU CAN'T HAVE NULLS IN HERE IT FUCKING BREAKS!
    final Map<String, dynamic> tags = fileMetadata['tags'];

    return FileMetadata(fileId, width, height, mime, duration, tags);
  }
}

// MARK: SEARCH RESULTS

class TagSuggest {
  final String value;
  final int count;

  TagSuggest(this.value, this.count);

  @override
  String toString() {
    return '{value: $value, count: $count}';
  }
}

List<TagSuggest> parseSearchResults(String query) {
  final json = jsonDecode(query);
  final List<dynamic> tags = json['tags'];
  return tags.take(8).map((e) => TagSuggest(e['value'], e['count'])).toList();
}
