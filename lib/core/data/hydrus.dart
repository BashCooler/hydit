import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'parser.dart';


Future<void> main() async {

  Client client = Client(accessKey: '86106807bd3cfe58cd0c5664981799dbaf978454a91b26afd3c5a60e3ad2c813');
  Stopwatch watch = Stopwatch();
  watch.start();
  var response = await client.getFileMetadata([182560646]);
  log(response.toString());
  log(watch.elapsedMilliseconds.toString());

  // var tags = ['creator:呵呜阿花', 'title:白丝秦喵喵。'];
}


class Client {
  static const int version = 81;

  String? accessKey;
  String host = 'localhost';
  int port = 45869;

  Client({this.accessKey, this.host = 'localhost', this.port = 45869});

  void updateClient({required String key, required Uri uri}) {
    accessKey = key;
    host = uri.host;
    port = uri.port;
  }

  // MARK: REQUEST

  Future<String> request(String method, String path, [Map<String, dynamic>? params]) async {
    final response = await getResponse(method, path, params);
    return response.body;
  }

  Future<Uint8List> requestBytes(String method, String path, [Map<String, dynamic>? params]) async {
    final response = await getResponse(method, path, params);
    return response.bodyBytes;
  }

  Future<http.Response> getResponse(String method, String path, Map<String, dynamic>? params) async {
    http.Response response;
    switch (method) {
      case 'get':
        response = await get(path, params);
      case 'post':
        throw UnimplementedError();
      default:
        throw Exception('No such http method "$method"');
    }
    return response;
  }

  Future<http.Response> get(String path, [Map<String, dynamic>? params]) async {
    http.Response response;
    try {
      response = await http.get(
          Uri.http('$host:$port', path, params?.map((k,v) => MapEntry(k,'$v'))),
          headers: { 'Hydrus-Client-API-Access-Key' : accessKey ?? '' }
      );
    } on SocketException catch (e, s) {
      throw Error.throwWithStackTrace(mapSocketException(e), s);
    }

    return response;
  }

  // MARK: BUILD URL

  String buildImageUrl(int id, {bool thumbnail = false}) => ""
      "http://$host:$port/get_files/"
      "${thumbnail ? "thumbnail" : "file"}"
      "?file_id=$id"
      "&Hydrus-Client-API-Access-Key=$accessKey";

  // Documentation: https://hydrusnetwork.github.io/hydrus/developer_api.html

  // MARK: ACCESS MANAGEMENT

  Future<String> getApiVersion() {
    return request('get', 'api_version');
  }

  Future<String> getRequestNewPermission(String name, {bool? permitsEverything, List<int>? basicPermissions}) {

    final Map<String, dynamic> params = {
      'name': name,
      'permits_everything': permitsEverything,
      'basic_permissions': basicPermissions,
    };

    return request('get', 'request_new_permissions', params);
  }

  Future<String> getVerifyAccessKey() {
    return request('get', 'verify_access_key');
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
      'tags': encodeTags(tags),
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

    final response = await request('get', '/get_files/search_files', params);
    final decoded = jsonDecode(response) as Map<String, dynamic>;

    if (decoded['file_ids'] == null) {
      switch (decoded['status_code']) {
        case 400:
          throw HydrusBadRequestException(decoded['error']);
        case 403:
          throw HydrusInsufficientCredentialsException(decoded['error']);
        default:
          throw HydrusUnknownException();
      }
    }

    return (decoded['file_ids'] as List).cast<int>();
  }

  Future<List<Map<String, dynamic>>> getFileMetadata(List<int> fileIds, {
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
      'file_ids': fileIds,
      'only_return_identifiers': onlyReturnIdentifiers,
      'only_return_basic_information': onlyReturnBasicInformation,
      'detailed_url_information': detailedUrlInformation,
      'include_blurhash': includeBlurhash,
      'include_milliseconds': includeMilliseconds,
      'include_notes': includeNotes,
      'include_services_object': includeServicesObject,
    };
    params.removeWhere((k, v) => (v == null));

    final response = await request('get', '/get_files/file_metadata', params);
    return parseMetadata(response);
  }

  // MARK: GET FILE

  Future<Uint8List> getThumbnail(dynamic fileIdOrHash) async {
    Map<String, dynamic> params = _getImageParams(fileIdOrHash);
    return requestBytes('get', '/get_files/thumbnail', params);
  }

  Future<Uint8List> getFile(dynamic fileIdOrHash, [bool? download]) async {
    Map<String, dynamic> params = _getImageParams(fileIdOrHash);
    return requestBytes('get', '/get_files/file', params);
  }

  Map<String, dynamic> _getImageParams(dynamic fileIdOrHash) {
    final Map<String, dynamic> params = {};
    final type = fileIdOrHash.toString().length == 64 ? 'hash' : 'file_id';
    params[type] = fileIdOrHash;
    return params;
  }

  // MARK: TAGS

  Future<String> getSearchTags(String tag, {
    // List<String>? fileDomain,
    // String? tagServiceKey,
    String? tagDisplayType,
  }) async {
    final Map<String, dynamic> params = {
      'search': tag,
      // 'file_domain': fileDomain,
      // 'tag_service_key': tagServiceKey,
      'tag_display_type': tagDisplayType,
    };
    params.removeWhere((k, v) => (v == null));

    return await request('get', '/add_tags/search_tags', params);
  }
}

// MARK: METHODS

String encodeTags(List<String> tagList) {

  // Replace special symbols with Unicode escape sequences (like \uxxxx)
  String encodeUnicode(String input) {
    return input.replaceAllMapped(
        RegExp(r'[^\x00-\x7F]'),
            (Match m) => '\\u${m.group(0)!.codeUnitAt(0).toRadixString(16).padLeft(4, '0')}'
    );
  }

  final tagsUnicode = tagList.map((tag) => '"${encodeUnicode(tag)}"').toList();
  final jsonString = '[${tagsUnicode.join(", ")}]';
  return Uri.encodeComponent(jsonString);
}

// MARK: EXCEPTIONS

sealed class HydrusException implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stack;

  HydrusException(this.message, [this.cause, this.stack]);

  @override
  String toString() => '$runtimeType: $message';
}

HydrusException mapSocketException(SocketException e) {
  final code = e.osError?.errorCode;

  switch (code) {
    case 1225:
    case 111:
      return HydrusNoServiceException(e);

    case 121:
    case 110:
      return HydrusTimeoutException(e);

    case 11001:
      throw HydrusUnknownHostException(e);

    default:
      return HydrusUnknownException(e);
  }
}

class HydrusNoServiceException extends HydrusException {
  static const String msg =
      'No connection with Hydrus. You reached the target IP/port but no one is '
      'listening. Is your client running?';

  HydrusNoServiceException(SocketException e) : super('$msg\nCaused by: $e');
}

class HydrusTimeoutException extends HydrusException {
  static const String msg =
      'No response (timeout). The host took your request and sent no response. '
      'Is this the correct host?';

  HydrusTimeoutException(SocketException e) : super('$msg\nCaused by: $e');
}

class HydrusBadRequestException extends HydrusException {
  HydrusBadRequestException(super.message);
}

class HydrusInsufficientCredentialsException extends HydrusException {
  HydrusInsufficientCredentialsException(super.message);
}

class HydrusUnknownHostException extends HydrusException {
  static const String msg = 'This host is unknown. Probably wrong URI.';
  HydrusUnknownHostException(SocketException e) : super('$msg\nCaused by: $e');
}

class HydrusUnknownException extends HydrusException {
  static const String msg = 'Unknown error.';
  final SocketException? e;

  HydrusUnknownException([this.e]) : super(e == null ? msg : '$msg\nCaused by: $e');
}
