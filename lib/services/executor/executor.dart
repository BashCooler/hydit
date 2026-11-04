import 'dart:async';
import 'dart:developer';

import 'package:hydit/utils/utils.dart';

import 'extensions.dart';
import 'result.dart';


Future<Result<T>> runCatching<T>(FutureOr<T> Function() f) async {
  try {
    return Success(await f());
  } catch (e) {
    return Failure(e);
  }
}


extension SafeExecuteAsync<T> on Future<T> {
  Future<Result<T>> run() async {
    try {
      return Success(await this);
    } catch (e) {
      return Failure(e);
    }
  }

  Future<Result<T>> runMatch({
    required void Function(T v) ok,
    required void Function(Object e) err,
  }) => run().match(ok: ok, err: err);
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

  Future<T> measure() async {
    final watch = Stopwatch()
      ..start();
    try {
      return await this;
    } finally {
      log(watch.elapsedMilliseconds.toString());
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
