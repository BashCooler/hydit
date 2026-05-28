import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;


class Http {
  String url = 'localhost:45869';

  final Map<String, String> headers = {};

  Http([Uri? uri, String? key]) {
    update(uri, key);
  }

  String get key => headers['Hydrus-Client-API-Access-Key'] ?? '';

  void update([Uri? uri, String? key]) {
    if (uri?.host != null) url = uri.toString();
    if (key != null) headers['Hydrus-Client-API-Access-Key'] = key;
  }

  Future<String> get(String path, [Map<String, dynamic>? params]) {
    return http.get(
      Uri.http(url, path, params?.prepared),
      headers: headers,
    ).timeout(Duration(seconds: 5)).then((r) => r.body);
  }

  Future<Uint8List> getBytes(String path, [Map<String, dynamic>? params]) {
    return http.get(
      Uri.http(url, path, params?.prepared),
      headers: headers,
    ).timeout(Duration(seconds: 5)).then((r) => r.bodyBytes);
  }

  Future<int> postStatus(String path, [Map<String, dynamic>? params]) {
    return http.post(
      Uri.http(url, path),
      headers: {
        ...headers,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(params),
    ).timeout(Duration(seconds: 5)).then((r) => r.statusCode);
  }
}


extension Prepare on Map<String, dynamic> {
  Map<String, String> get prepared => map((k,v) => MapEntry(k,'$v'));
}
