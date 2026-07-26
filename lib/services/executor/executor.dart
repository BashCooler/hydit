import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/services/executor/handler.dart';

import 'models.dart';


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


extension ToSuccess<T> on T {
  Success<T> toSuccess() => Success(this);
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
      FutureOr<void> Function(Failure<T> failure) callback) async {

    final result = await this;

    if (result is Failure<T>) {
      await callback(result);
    }

    return result;
  }

  Future<Result<T>> delay(double seconds) async {

    final wait = await Future.wait<Result<T>?>([
      this,
      Future.delayed(seconds.s),
    ]);

    return wait.first!;
  }
}


extension MapResult<T> on Future<Result<T>> {

  Future<Result<R>> map<R>(FutureOr<R> Function(T data) f) async {
    final result = await this;

    switch (result) {
      case Success<T>(data: final data):
        return Success<R>(await f(data));
      case Failure<T>():
        return Failure<R>.from(result);
    }
  }
}


extension Unwrap<T> on Future<Result<T>> {

  Future<T?> unwrap() async => (await this).unwrap();
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
