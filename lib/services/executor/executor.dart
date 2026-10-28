import 'dart:async';

import 'package:hydit/services/executor/extensions.dart';
import 'package:hydit/utils/utils.dart';

import 'result.dart';


extension SafeExecuteAsync<T> on Future<T> {
  Future<Result<T>> run() async {
    try {
      return Success(await this);
    } catch (e) {
      return Failure(e);
    }
  }

  Future<Result<T>> match({
    required void Function(T v) ok,
    required void Function(Object e) err,
  }) {
    return run().tapSuccess(ok).tapFailure(err);
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
