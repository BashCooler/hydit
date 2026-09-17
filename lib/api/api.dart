import 'dart:async';
import 'dart:typed_data';

import 'package:get/get.dart';

import 'package:hydit/api/params.dart';
import 'package:hydit/services/storage.dart';
import 'package:hydit/api/enums.dart';

import 'dio.dart';


class HydrusApi with DioClient {
  static const int version = 94;

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

  Future<String> getApiVersion() => get('/api_version');

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

  Future<String> getFileMetadata(List<int> ids, {
    bool onlyReturnBasicInformation = false,
    bool includeServicesObject = false,
  }) =>
      get(
        '/get_files/file_metadata',
        params: {
          'file_ids': ids,
          'only_return_basic_information': onlyReturnBasicInformation,
          'include_services_object': includeServicesObject,
        },
      );

  // MARK: FILES

  Future<Uint8List> getFile(int fileId, {bool download = false}) =>
      get<Uint8List>(
        '/get_files/file',
        file: true,
        params: {
          'file_id': fileId,
          'download': download,
        },
      );

  Future<void> deleteFiles(List<int> ids) =>
      post(
        '/add_files/delete_files',
        params: {
          'file_ids': ids,
        },
      );

  Future<void> archiveFiles(List<int> ids) =>
      post(
        '/add_files/archive_files',
        params: {
          'file_ids': ids,
        },
      );

  Future<void> unarchiveFiles(List<int> ids) =>
      post(
        '/add_files/unarchive_files',
        params: {
          'file_ids': ids,
        },
      );

  // MARK: TAGS

  Future<String> getSearchTags(String tag, {
    TagDisplayType tagDisplayType = .storage,
  }) =>
      get(
        '/add_tags/search_tags',
        params: {
          'search': tag,
          'tag_display_type': tagDisplayType.toString(),
        },
      );

  Future<void> postAddTags(AddTagsParams params) =>
      post(
        '/add_tags/add_tags',
        params: params.toMap(),
      );
}
