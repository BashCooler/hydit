import 'dart:async';
import 'dart:developer';

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


extension FutureUtils<T> on Future<T> {

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

  Future<T> withMinDuration(Duration d) => Future.wait([
    this,
    Future.delayed(d),
  ]).then((r) => r.first);
}
