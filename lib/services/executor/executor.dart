import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:hydit/utils/errors.dart';

import 'package:hydit/utils/utils.dart';

import 'models.dart';


class Executor {
  Executor._();

  static Future<Result<T>> run<T>(Future<T> Function() action) async {
    try {
      return Success(await action());

    } on DioException catch (e) {

      return HydrusConnectionError(e).toFailure();

    } on PlatformException catch (e) {

      return PlatformError(e).toFailure();
    }
  }
}


extension TryOr<T> on T? {

  R tryOr<R>(R Function(T v) f, {
    required R or,
  }) {
    final v = this;

    if (v == null) {
      return or;
    }

    try {
      return f(v);
    } catch (e) {
      return or;
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


extension Delay<T> on Future<Result<T>> {

  Future<Result<T>> delay(double seconds) async {

    final wait = await Future.wait<Result<T>?>([
      this,
      Future.delayed(seconds.s),
    ]);

    return wait.first!;
  }
}
