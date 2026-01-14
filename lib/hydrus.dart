import 'dart:io';

import 'package:http/http.dart' as http;

Future<void> main() async {

  Client client = Client('86106807bd3cfe58cd0c5664981799dbaf978454a91b26afd3c5a60e3ad2c813');

  var tags = ['creator:呵呜阿花', 'title:白丝秦喵喵。'];
  print(
    await client.getSearchFiles(tags)
  );

  // TODO довести до ума, как и что оно должно сохранять (см. ниже)
  var response = await client.getFile(166084067);
  var file = File('test_image.jpg');
  await file.writeAsBytes(response.bodyBytes);
}


class Client {
  static const int version = 81;

  String apiUrl = 'localhost';
  String accessKey;
  int port = 45869;

  Client(this.accessKey, [this.apiUrl = 'localhost', this.port = 45869]);

  // MARK: REQUEST

  Future<String> request(String method, String path, [Map<String, dynamic>? params]) async {

    http.Response response;

    try {
      response = await http.get(
          Uri.http('$apiUrl:$port', path, params?.map((k,v) => MapEntry(k,'$v'))),
          headers: { 'Hydrus-Client-API-Access-Key' : accessKey, }
      );
    } on SocketException catch (e, s) {
      throw Error.throwWithStackTrace(mapSocketException(e), s);
    }

    return response.body;
  }

  // Documentation: https://hydrusnetwork.github.io/hydrus/developer_api.html

  // MARK: ACCESS MANAGEMENT

  Future<String> getApiVersion() {
    return request('get', 'api_version');
  }

  Future<String> getRequestNewPermission(String name, [bool? permitsEverything, List<int>? basicPermissions]) {

    Map<String, dynamic> params = {
      'name': name,
      'permits_everything': permitsEverything,
      'basic_permissions': basicPermissions,
    };

    return request('get', 'request_new_permissions', params);
  }

  // MARK: SEARCHING AND FETCHING FILES

  Future<String> getSearchFiles(
      List<String> tags, [
        // fileDomain
        // tagServiceKey
        bool? includeCurrentTags,
        bool? includePendingTags,
        int? fileSortType,
        bool? fileSortAsc,
        bool? returnFileIds,
        bool? returnHashes,
      ]
    ) {
    Map<String, dynamic> params = {
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

    return request('get', '/get_files/search_files', params);
  }

  Future<http.Response> getFile(dynamic fileIdOrHash, [bool? download]) async {
    Map<String, dynamic> params = {};
    if (fileIdOrHash.toString().length == 64) {
      params['hash'] = fileIdOrHash;
    }
    else {
      params['file_id'] = fileIdOrHash;
    }

    var response = await http.get(
        Uri.http('$apiUrl:$port', '/get_files/file', params.map((k,v) => MapEntry(k,'$v'))),
        headers: { 'Hydrus-Client-API-Access-Key' : accessKey, }
    );

    return response;
  }
}


// TODO навести порядок:
// - объединить в отдельный класс с тем, что (см. выше.)
// - или лучше создать универсальный request
String encodeTags(List<String> tagList) {

  // Replace special symbols with Unicode escape sequences (like \uxxxx)
  String encodeUnicode(String input) {
    return input.replaceAllMapped(
        RegExp(r'[^\x00-\x7F]'),
            (Match m) => '\\u${m.group(0)!.codeUnitAt(0).toRadixString(16).padLeft(4, '0')}'
    );
  }

  List<String> tagsUnicode = tagList.map((tag) => '"${encodeUnicode(tag)}"').toList();
  String jsonString = '[${tagsUnicode.join(", ")}]';
  return Uri.encodeComponent(jsonString);
}


class BasicPermissions {
  static const importAndEditURLs = 0;
  static const importAndDeleteFiles = 1;
  static const editFileTags = 2;
  static const searchForAndFetchFiles = 3;
  static const managePages = 4;
  static const manageCookiesAndHeaders = 5;
  static const manageDatabase = 6;
  static const editFileNotes = 7;
  static const editFileRelationships = 8;
  static const editFileRatings = 9;
  static const managePopups = 10;
  static const editFileTimes = 11;
  static const commitPending = 12;
  static const seeLocalPaths = 13;
}


class FileSortType {
  static const fileSize = 1;
  static const duration = 2;
  static const importTime = 3;
  static const filetype = 4;
  static const random = 5;
  static const width = 6;
  static const height = 7;
  static const ratio = 8;
  static const numberOfPixels = 9;
  static const numberOfTags = 10;
  static const numberOfMediaViews = 11;
  static const totalMediaViewTime = 12;
  static const approximateBitrate = 13;
  static const hasAudio = 14;
  static const modifiedTime = 15;
  static const frameRate = 16;
  static const numberOfFrames = 17;
  static const lastViewedTime = 18;
  static const archiveTimestamp = 19;
  static const hashHex = 20;
  static const pixelHashHex = 21;
  static const blurHash = 22;
  static const averageColourLightness = 23;
  static const averageColourChromaticMagnitude = 24;
  static const averageColourGreenRedAxis = 25;
  static const averageColourBlueYellowAxis = 26;
  static const averageColourHue = 27;
}


// EXCEPTIONS

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

class HydrusUnknownException extends HydrusException {
  static const String msg = 'Unknown error.';

  HydrusUnknownException(SocketException e) : super('$msg\nCaused by: $e');
}
