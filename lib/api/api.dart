import 'dart:async';
import 'dart:typed_data';

import 'package:hydit/api/params.dart';

import 'dio.dart';


class HydrusApi with DioClient {
  static const int version = 81;

  HydrusApi({Uri? uri, String? key}) {
    update(uri, key);
  }

  // MARK: ACCESS MANAGEMENT

  Future<String> getApiVersion() {
    return get('/api_version');
  }

  Future<String> getRequestNewPermission(String name, {
    bool? permitsEverything,
    List<int>? basicPermissions,
  }) {
    final Map<String, dynamic> params = {
      'name': name,
      'permits_everything': permitsEverything,
      'basic_permissions': basicPermissions,
    };
    return get('/request_new_permissions', params: params);
  }

  Future<String> getVerifyAccessKey() {
    return get('/verify_access_key');
  }

  Future<String> getServices() {
    return get('/get_services');
  }

  Future<String> getService({String? name, String? key}) {
    final Map<String, dynamic> params = {};

    if (key != null) params['key'] = key;
    if (name != null) params['service_name'] = name;

    return get('/get_service', params: params);
  }

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
    bool? createNewFileIds,
    bool? onlyReturnIdentifiers,
    bool? onlyReturnBasicInformation,
    bool? detailedUrlInformation,
    bool? includeBlurhash,
    bool? includeMilliseconds,
    bool? includeNotes,
    bool includeServicesObject = false,
  }) {
    final Map<String, dynamic> params = {
      'file_ids': ids,
      'only_return_identifiers': onlyReturnIdentifiers,
      'only_return_basic_information': onlyReturnBasicInformation,
      'detailed_url_information': detailedUrlInformation,
      'include_blurhash': includeBlurhash,
      'include_milliseconds': includeMilliseconds,
      'include_notes': includeNotes,
      'include_services_object': includeServicesObject,
    };
    params.removeWhere((k, v) => (v == null));

    return get('/get_files/file_metadata', params: params);
  }

  // MARK: GET FILES

  Future<Uint8List> getThumbnail(int fileId) {
    final params = {
      'file_id': fileId,
    };
    return get<Uint8List>('/get_files/thumbnail', params: params);
  }

  Future<Uint8List> getFile(dynamic fileId, {bool download = false}) {
    final params = {
      'file_id': fileId,
      'download': download,
    };
    return get<Uint8List>('/get_files/file', params: params);
  }

  // MARK: ADD FILES

  Future<void> deleteFiles(List<int> ids) =>
      post<void>(
        '/add_files/delete_files',
        params: {
          'file_ids': ids,
        },
      );

  // MARK: TAGS

  Future<String> getSearchTags(String tag, {
    // List<String>? fileDomain,
    // String? tagServiceKey,
    String? tagDisplayType,
  }) {
    final Map<String, dynamic> params = {
      'search': tag,
      // 'file_domain': fileDomain,
      // 'tag_service_key': tagServiceKey,
      'tag_display_type': tagDisplayType,
    };
    params.removeWhere((k, v) => (v == null));

    return get('/add_tags/search_tags', params: params);
  }

  Future<void> postAddTags(AddTagsParams params) {
    return post<void>('/add_tags/add_tags', params: params.toMap());
  }
}
