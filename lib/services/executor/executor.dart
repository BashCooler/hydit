import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/services/executor/handler.dart';

part 'models.dart';


class Executor {
  Executor._();

  static Future<Result<T>> run<T>(Future<T> Function() action) async {
    try {
      return Success(await action());

    } on DioException catch (e) {

      return Handler.handleDioException(e);

    } on PlatformException catch (e) {

      return Handler.handlePlatformException(e);
    }
  }
}


extension SafeExecuteAsync<T> on Future<T> {
  /// Safely runs an [action], handles [DioException] and
  /// [PlatformException].
  Future<Result<T>> run() => Executor.run(() => this);
}


extension Loading<T> on Future<T> {

  /// Toggles [loading] on, then awaits for a composable
  /// function to complete, then toggles [loading] off.
  ///
  /// Parameter [loading] must have `ValueNotifier<bool>`
  /// signature, this means it should have a `bool value`
  /// property
  Future<T> loading(dynamic loading) async {
    loading.value = true;
    try {
      return await this;
    } finally {
      loading.value = false;
    }
  }
}


extension TapsAsync<T> on Future<Result<T>> {

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

  Future<Result<T>> delay(double seconds) async {

    final wait = await Future.wait<Result<T>?>([
      this,
      Future.delayed(seconds.s),
    ]);

    return wait.first!;
  }
}


extension Taps<T> on Result<T> {

  Result<T> tapSuccess(
      FutureOr<void> Function(T data) callback) {

    if (this case Success<T>(data: final data)) {
      callback(data);
    }

    return this;
  }

  Result<T> tapFailure(
      FutureOr<void> Function(String title, String message) callback) {

    if (this case Failure<T>(title: final title, message: final message)) {
      callback(title, message);
    }

    return this;
  }
}
