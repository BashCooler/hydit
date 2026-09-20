import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/services.dart';
import 'package:deep_pick/deep_pick.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/services/executor.dart';


class Handler {
  const Handler._();

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
        return Failure('Client error', 'No host provided');

      case _:
        return handleUnknownError(e);
    }
  }

  static Result<T> handleBadResponse<T>(DioException e) {
    final data = e.response?.data as String?;

    final title = data.tryOr(
      (v) => v.pick('exception_type').asStringOrThrow().format(),
      or: 'Bad response',
    );

    final message = data.tryOr(
      (v) => v.pick('error').asStringOrThrow().replaceAll('!', ''),
      or: 'The received response does not look like a valid Hydrus response',
    );

    return Failure(title, message);
  }

  static Result<T> handleConnectionError<T>(DioException e) => Failure(
    'Connection refused',
    switch (e.error) {
      SocketException(osError: OSError(errorCode: 101)) => 'No internet connection',
      _ => 'No running Hydrus client found',
    },
  );

  static Result<T> handleTimeout<T>(DioException e) => Failure(
    'Connection timeout',
    'No response from Hydrus',
  );

  static Result<T> handleUnknownError<T>(DioException e) {
    return Failure(
      e.error.runtimeType.toString().format(),
      e.toString(),
    );
  }

  static Result<T> handlePlatformException<T>(PlatformException e) {
    return Failure('Platform error', e.toString());
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
