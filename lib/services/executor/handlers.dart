import 'package:dio/dio.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/services.dart';
import 'package:deep_pick/deep_pick.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:hydit/utils/utils.dart';

import 'executor.dart';


class Handler {

  static Future<Result<T>> handleDioException<T>(DioException e) async {
    switch (e.type) {
      case .badResponse:
        return handleBadResponse(e);

      case .connectionError:
        return handleConnectionError(e);

      case .sendTimeout:
      case .receiveTimeout:
      case .connectionTimeout:
        return handleTimeout(e);

      case .unknown when e.error.runtimeType == ArgumentError:
        return Failure('Client error', 'No host provided', e);

      case _:
        return handleUnknownError(e);
    }
  }

  static Future<String?> connectionReport() async {
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

    return null;
  }

  static Result<T> handleBadResponse<T>(DioException e) {
    final data = e.response?.data as String?;

    String title =
        'Bad response';
    String message =
        'The received response does not look like a valid Hydrus response';
    Object? details;

    try {
      final json = data?.decode();

      final exception = pick(json, 'exception_type')
          .asStringOrNull();

      if (exception != null) title = exception.format();

      final error = pick(json, 'error')
          .asStringOrNull()
          ?.replaceAll('!', '');

      if (error != null) message = error;

    } catch (e) {
      details = e;
    }

    final result = FailureBuilder<T>()
      ..title = title
      ..message = message
      ..details = details ?? e;

    return result();
  }

  static Future<Result<T>> handleConnectionError<T>(DioException e) async {
    final report = await connectionReport();

    final result = FailureBuilder<T>()
      ..title = 'Connection refused'
      ..message = report ?? 'No running Hydrus client found'
      ..details = e;

    return result();
  }

  static Future<Result<T>> handleTimeout<T>(DioException e) async {
    final report = await connectionReport();

    final result = FailureBuilder<T>()
      ..title = 'Connection timeout'
      ..message = report ?? 'No response from Hydrus'
      ..details = e;

    return result();
  }

  static Result<T> handleUnknownError<T>(DioException e) {

    final result = FailureBuilder<T>()
      ..title = e.error.runtimeType.toString().format()
      ..message = e.toString()
      ..details = e;

    return result();
  }

  static Result<T> handlePlatformException<T>(PlatformException e) {
    return Failure('Platform error', e.toString(), e);
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
