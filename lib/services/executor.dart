import 'dart:async';
import 'dart:convert' hide json;
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide GetStringUtils;
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

  @Deprecated(
      'Use the `run` extension instead, it support a much more readable'
      'fluent api')
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

  /// Set [loading] = true, then [action], then [loading]= false.
  static Future<void> refresh(RxBool loading,
      Future<void> Function() action) async {

    loading.value = true;
    try {
      await action();
    } finally {
      loading.value = false;
    }
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


extension Unwrap<T> on Result<T> {

  T? unwrap({void Function(String title, String message)? onFailure}) {
    switch (this) {
      case Success(data: final data):
        return data;
      case Failure(title: final title, message: final message):
        onFailure?.call(title, message);
        return null;
    }
  }
}


extension SafeExecute<T> on Future<T> {
  /// Safely runs an [action], handles [DioException]s.
  Future<Result<T>> run() => Executor.run(() => this);

  Future<T> loading(RxBool loading) async {
    loading.value = true;
    try {
      return await this;
    } finally {
      loading.value = false;
    }
  }
}


extension FutureOperations<T> on Future<Result<T>> {

  Future<Result<T>> onSuccess(
      FutureOr<void> Function(T value) callback) async {

    final result = await this;

    if (result case Success<T>(data: final data)) {
      await callback(data);
    }

    return result;
  }

  Future<Result<T>> onFailure(
      FutureOr<void> Function(String title, String message) callback) async {

    final result = await this;

    if (result case Failure<T>(title: final title, message: final message)) {
      await callback(title, message);
    }

    return result;
  }

  Future<T?> unwrap() async {
    return (await this).unwrap();
  }
}
