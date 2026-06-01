import 'package:dio/dio.dart';


mixin class DioClient {
  final dio = Dio()
    ..options.baseUrl = 'http://127.0.0.1:45869'
    ..options.connectTimeout = const Duration(seconds: 3);

  void updateDio([Uri? uri, String? key]) {
    if (uri != null) dio.options.baseUrl = uri.toString();
    if (key != null) dio.options.headers['Hydrus-Client-API-Access-Key'] = key;
  }

  Future<T> get<T>(String path,
      {Map<String, dynamic>? params, T Function(Response r)? parser}) {
    return dio.get<T>(path, queryParameters: params)
        .then((r) => parser?.call(r) ?? r.data!);
  }

  Future<T> post<T>(String path, {
    Map<String, dynamic>? params,
    T Function(Response r)? parser,
    bool file = false,
  }) {
    final options = Options(headers: {
      ...dio.options.headers,
      'Content-Type': file ? 'application/octet-stream' : 'application/json',
    });
    return dio.post<T>(path, queryParameters: params, options: options)
        .then((r) => parser?.call(r) ?? r.data as T);
  }
}