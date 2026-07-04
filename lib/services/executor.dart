import 'dart:async';
import 'dart:convert' hide json;

import 'package:dio/dio.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/services.dart';
import 'package:deep_pick/deep_pick.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


class CancellationToken {
  bool _cancelled = false;

  bool get cancelled => _cancelled;

  void cancel() {
    _cancelled = true;
  }
}


sealed class Result<T> {

  T? unwrap() {
    if (this case Success(data: final data)) {
      return data;
    }
    return null;
  }

  T unwrapOrThrow() {
    if (this case Success(data: final data)) {
      return data;
    }
    throw StateError('Registered an attempt to unwrap a Failure');
  }
}

class Success<T> extends Result<T> {
  final T data;

  Success(this.data);
}

class Failure<T> extends Result<T> {
  final String title;
  final String message;
  final Object? details;

  Failure(this.title, this.message, [this.details]);
}


class Executor {
  Executor._();

  static Future<Result<T>> run<T>(Future<T> Function() action) async {
    try {
      return Success(await action());

    } on DioException catch (e) {

      switch (e.type) {

        case .badResponse when e.response?.data == null:
          return Failure('Bad response', 'Empty response', e);

        case .badResponse:

          final data = e.response?.data as String?;

          final json = data != null ? jsonDecode(data) : null;

          final error = pick(json, 'exception_type')
              .asStringOrNull()
              ?.format();

          final message = pick(json, 'error')
              .asStringOrNull()
              ?.replaceAll('!', '');

          return Failure(error ?? 'Bad response', message ?? 'Unknown error');

        case .connectionError:

          return Failure(
            'Connection refused',
            await _connectionReport() ?? 'No running Hydrus client found',
          );

        case .sendTimeout:
        case .receiveTimeout:
        case .connectionTimeout:

          return Failure(
            'Connection timeout',
              await _connectionReport() ?? 'No response from Hydrus'
          );

        case .unknown when e.error.runtimeType == ArgumentError:

          return Failure('Client error', 'No host provided');

        case _:

          return Failure(
            e.error.runtimeType.toString().format(),
            e.toString(),
          );
      }

    } on PlatformException catch (e) {

      return Failure('Platform error', e.toString(), e);
    }
  }

  static Future<String?> _connectionReport() async {
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


extension SafeExecute<T> on Future<T> {
  /// Safely runs an [action], handles [DioException] and
  /// [PlatformException].
  Future<Result<T>> run() => Executor.run(() => this);
}


extension FutureOperations<T> on Future<Result<T>> {
  /// Toggles [loading] on, then awaits for a composable
  /// function to complete, then toggles [loading] off.
  ///
  /// Parameter [loading] must have `ValueNotifier<bool>`
  /// signature, this means it should have a `bool value`
  /// property
  Future<Result<T>> loading(dynamic loading) async {
    loading.value = true;
    try {
      return await this;
    } finally {
      loading.value = false;
    }
  }

  Future<Result<T>> tapSuccess(
      FutureOr<void> Function(T data) callback) async {

    final result = await this;

    if (result case Success<T>(data: final data)) {
      await callback(data);
    }

    return result;
  }

  Future<Result<T>> tapFailure(
      FutureOr<void> Function(String title, String message) callback) async {

    final result = await this;

    if (result case Failure<T>(title: final title, message: final message)) {
      await callback(title, message);
    }

    return result;
  }

  Future<T?> unwrap() async => (await this).unwrap();
}


class ExecutorQueue {
  final List<Future<Result>> _operations = [];

  ExecutorQueue queue(Future<Result> operation) {
    _operations.add(operation);
    return this;
  }

  ExecutorQueue queueAll(Iterable<Future<Result>> operations) {
    _operations.addAll(operations);
    return this;
  }

  Future<Result<void>> run() async {

    for (final operation in _operations) {
      final result = await operation;

      if (result is Failure) return result;
    }

    return Success(null);
  }
}


extension ChunckedList<T> on List<T> {

  Iterable<List<T>> chunked(int size) sync* {
    for (var i = 0; i < length; i += size) {
      yield sublist(
        i,
        (i + size).clamp(0, length),
      );
    }
  }
}
