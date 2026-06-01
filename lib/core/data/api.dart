import 'dart:async';
import 'dart:typed_data';

import 'package:hydit/core/data/dio.dart';
import 'package:hydit/core/data/http.dart';
import 'package:hydit/utils/dictionaries.dart';


class HydrusApi with DioClient {
  static const int version = 81;
  final Http http;

  HydrusApi({Uri? uri, String? key}) : http = Http(uri, key) {
    update(uri, key);
  }

  String get url => '${http.url.host}:${http.url.port}';
  String get key => http.key;

  void update([Uri? uri, String? key]) {
    updateDio(uri, key);
    http.update(uri, key);
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

  Future<List<int>> getSearchFiles(List<String> tags, {
    // List<String>? fileDomain,
    // String? tagServiceKey,
    bool? includeCurrentTags,
    bool? includePendingTags,
    int? fileSortType,
    bool? fileSortAsc,
    bool? returnFileIds,
    bool? returnHashes,
  }) async {
    final Map<String, dynamic> params = {
      'tags': _encodeTags(tags),
      // 'file_domain': fileDomain,
      // 'tag_service_key': tagServiceKey,
      'include_current_tags': includeCurrentTags,
      'include_pending_tags': includePendingTags,
      'file_sort_type': fileSortType,
      'file_sort_asc': fileSortAsc,
      'return_file_ids': returnFileIds,
      'return_hashes': returnHashes,
    };
    params.removeWhere((k, v) => (v == null));

    final response = await get<Map<String, dynamic>>(
      '/get_files/search_files',
      params: params,
    );

    return (response['file_ids'] as List).cast<int>();
  }

  Future<String> getFileMetadata(List<int> ids, {
    bool? createNewFileIds,
    bool? onlyReturnIdentifiers,
    bool? onlyReturnBasicInformation,
    bool? detailedUrlInformation,
    bool? includeBlurhash,
    bool? includeMilliseconds,
    bool? includeNotes,
    bool? includeServicesObject,
  }) async {
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

    return await http.get('/get_files/file_metadata', params: params);
  }

  // MARK: GET FILE

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

  Future<void> postAddTags(List<int> ids, String serviceKey, Action action,
      List<String> tags) {
    final Map<String, dynamic> params = {
      'file_ids': ids,
      'service_keys_to_actions_to_tags': {
        serviceKey: {
          "${action.value}": tags,
        }
      }
    };
    return http.post<void>('/add_tags/add_tags', params: params);
  }

  static String _encodeTags(List<String> tagList) {
    /// Replace special symbols with Unicode escape sequences (like \uXXXX)
    String encodeUnicode(String input) {
      return input.replaceAllMapped(
        RegExp(r'[^\x00-\x7F]'),
            (Match m) => '\\u${m
            .group(0)!
            .codeUnitAt(0)
            .toRadixString(16)
            .padLeft(4, '0')}',
      );
    }
    final tagsUnicode = tagList.map((tag) => '"${encodeUnicode(tag)}"').toList();
    final jsonString = '[${tagsUnicode.join(", ")}]';
    return Uri.encodeComponent(jsonString);
  }
}
