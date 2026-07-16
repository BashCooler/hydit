import 'package:dio/dio.dart';


mixin class DioClient {
  final dio = Dio()
    ..options.baseUrl = 'http://127.0.0.1:45869'
    ..options.connectTimeout = const Duration(seconds: 3);

  String get url => dio.options.baseUrl;
  String get key => dio.options.headers['Hydrus-Client-API-Access-Key'];

  void update(Uri uri, String key) {
    dio.options
      ..baseUrl = uri.replace(path: '').toString()
      ..headers['Hydrus-Client-API-Access-Key'] = key;
  }

  Future<T> get<T>(String path, {
    Map<String, dynamic>? params,
    bool file = false,
  }) {
    return dio.get<T>(
      path,
      queryParameters: params?.prepared,
      options: file ? Options(responseType: .bytes) : null,
    )
        .then((r) => r.data!);
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
    return dio.post<T>(path, data: params, options: options)
        .then((r) => parser?.call(r) ?? r.data as T);
  }
}


extension Prepare on Map<String, dynamic> {
  Map<String, String> get prepared => map((k,v) => MapEntry(k,'$v'));
}
