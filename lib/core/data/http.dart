import 'dart:convert';

import 'package:http/http.dart' as http;


class Http {
  Uri url = Uri(host: 'localhost', port: 45869);

  final Map<String, String> headers = {};

  Http([Uri? uri, String? key]) {
    update(uri, key);
  }

  String get key => headers['Hydrus-Client-API-Access-Key'] ?? '';

  void update([Uri? uri, String? key]) {
    if (uri != null) url = uri;
    if (key != null) headers['Hydrus-Client-API-Access-Key'] = key;
  }

  Future<T> get<T>(String path,
      {Map<String, dynamic>? params, T Function(http.Response r)? parser}) {
    return http.get(
      Uri.http('${url.host}:${url.port}', path, params?.prepared),
      headers: headers)
        .timeout(Duration(seconds: 5))
        .then((r) => parser?.call(r) ?? r.body as T);
  }

  Future<T> post<T>(String path,
      {Map<String, dynamic>? params, T Function(http.Response r)? parser}) {
    return http.post(
      Uri.http('${url.host}:${url.port}', path),
      headers: {
        ...headers,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(params))
        .timeout(Duration(seconds: 5))
        .then((r) => parser?.call(r) ?? r.body as T);
  }
}


extension Prepare on Map<String, dynamic> {
  Map<String, String> get prepared => map((k,v) => MapEntry(k,'$v'));
}
