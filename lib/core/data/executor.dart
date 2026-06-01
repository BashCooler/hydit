import 'dart:convert' hide json;

import 'package:dio/dio.dart';
import 'package:dartx/dartx.dart';
import 'package:deep_pick/deep_pick.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


sealed class Result<T> {}

class Success<T> extends Result<T> {
  final T data;

  Success({required this.data});
}

class Failure<T> extends Result<T> {
  final String title;
  final String message;

  Failure({required this.title, required this.message});
}


class Executor {
  Executor._();

  /// Safely runs an [action], handles [DioException]s, returns
  /// either [Success] or [Failure].
  ///
  /// [Success] contains data of type [T].
  ///
  /// [Failure] contains a title and a description of the error.
  static Future<Result<T>> run<T>(Future<T> Function() action) async {
    try {
      final data = await action();
      return Success(data: data);

    } on DioException catch (e) {
      final String title;
      final String message;

      switch (e.type) {
        case .badResponse when e.response?.data == null:
          title = 'Bad response';
          message = 'Unknown error';

        case .badResponse:
          final String data = e.response!.data;
          final json = jsonDecode(data);
          final String? exception = pick(json, 'exception_type')
              .asStringOrNull()
              ?.format();
          final String? description = pick(json, 'error')
              .asStringOrNull()
              ?.replaceAll('!', '');
          title = exception ?? 'Bad response';
          message = description ?? 'Unknown error';

        case .connectionError:
          title = 'Connection refused';
          message = await _connectionReport(
            defaultMessage: 'No running Hydrus client found',
          );

        case .sendTimeout:
        case .receiveTimeout:
        case .connectionTimeout:
          title = 'Connection timeout';
          message = await _connectionReport(
            defaultMessage: 'No response from Hydrus',
          );

        case .unknown when e.error.runtimeType == ArgumentError:
          title = 'Client error';
          message = 'No host provided';

        case _:
          title = e.error.runtimeType.toString().format();
          message =
              'Unknown error occurred with the type "${e.error.runtimeType}"';
      }

      return Failure(title: title, message: message);
    }
  }

  static Future<String> _connectionReport({String? defaultMessage}) async {
    final results = await (Connectivity().checkConnectivity());

    final connected = results.contains(ConnectivityResult.mobile)
        || results.contains(ConnectivityResult.wifi)
        || results.contains(ConnectivityResult.ethernet);

    if (!connected) {
      return 'No internet connection';
    }
    
    if (results.contains(ConnectivityResult.vpn)) {
      return 'This issue may be caused by an active VPN connection';
    }

    return defaultMessage ?? 'Unknown error';
  }
}


extension Format on String {
  // ignore: unnecessary_this
  String format() => this
      .replaceAll('Exception', '')
      .addSpaces()
      .toLowerCase()
      .trim()
      .capitalize();

  String addSpaces() =>
      replaceAllMapped(RegExp(r'(?<!^)(?=[A-Z])'), (match) => ' ');
}
