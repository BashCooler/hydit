import 'dart:async';
import 'dart:typed_data';

import 'package:get/get.dart';

import 'package:hydit/api/params.dart';
import 'package:hydit/services/storage.dart';
import 'package:hydit/api/enums.dart';
import 'package:hydit/utils/unicode.dart';

import 'dio.dart';
import 'models.dart';


class HydrusApi with DioClient {
  static const int version = 96;

  HydrusApi({
    required Uri uri,
    required String key,
  }) {
    update(uri, key);
  }

  /// Create an instance of [HydrusApi] with settings
  /// from [Storage].
  HydrusApi.load() {
    load();
  }

  /// Update api URL and access key with
  /// settings from [Storage].
  void load() {
    final box = Get.find<Storage>();

    final key = box.get('key') ?? '';
    final url = box.get('url') ?? '';

    update(Uri.parse(url), key);
  }

  // MARK: ACCESS MANAGEMENT

  Future<String> getVerifyAccessKey() => get('/verify_access_key');

  // MARK: SEARCHING AND FETCHING FILES

  Future<List<int>> getSearchFiles(SearchFilesParams params) {
    final request = get<Map<String, dynamic>>(
      '/get_files/search_files',
      params: params.toMap(),
    );
    return request
        .then((r) => r['file_ids'] as List)
        .then((l) => l.cast<int>());
  }

  Future<FileMetadataResponseDto> getFileMetadata(List<int> ids) =>
      get<String>(
        '/get_files/file_metadata',
        params: {
          'file_ids': ids,
          'include_services_object': false,
        },
      ).then(FileMetadataResponseDto.fromJson);

  // MARK: FILES

  Future<Uint8List> getFileAsBytes(int id) =>
      get<Uint8List>(
        '/get_files/file',
        file: true,
        params: {
          'file_id': id,
        },
      );

  /// Combined archive, unarchive and delete request.
  Future<void> editFiles(List<int> ids, {
    required AddFilesAction action,
  }) =>
      post(
        switch (action) {
          .archive => '/add_files/archive_files',
          .inbox => '/add_files/unarchive_files',
          .delete => '/add_files/delete_files',
        },
        params: {
          'file_ids': ids,
        },
      );

  // MARK: TAGS

  Future<SearchTagsDto> getSearchTags(String tag, {
    TagDisplayType tagDisplayType = .storage,
  }) =>
      get<String>(
        '/add_tags/search_tags',
        params: {
          'search': tag,
          'tag_display_type': switch (tagDisplayType) {
            .storage => 'storage',
            .display => 'display',
          },
        },
      ).then(SearchTagsDto.fromJson);

  Future<void> postAddTags(AddTagsParams params) =>
      post(
        '/add_tags/add_tags',
        params: params.toMap(),
      );

  Future<SiblingsAndParentsDto> getSiblingsAndParents(Iterable<String> tags) =>
      get<String>(
        '/add_tags/get_siblings_and_parents',
        params: {
          'tags': tags.toList().encode(),
        },
      ).then(SiblingsAndParentsDto.fromJson);

  // MARK: EXTRAS

  Future<PendingFile> getFile(int id) async {
    final bytes = await getFileAsBytes(id);

    final meta = await getFileMetadata([id]).then((r) => r.first);

    return PendingFile(bytes, name: meta.hash, mime: meta.mime);
  }

  String getFileUrl(int id, {FileUrlType type = .file}) => ''
      '$url/get_files/$type'
      '?file_id=$id'
      '&Hydrus-Client-API-Access-Key=$key';
}
