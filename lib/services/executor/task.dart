import 'dart:async';

import 'package:deep_pick/deep_pick.dart';
import 'package:hydit/services/executor.dart';


class Task<T> {
  final Future<Result<T>> Function() _run;

  const Task(this._run);

  Future<Result<T>> run() async {
    try {
      return await _run();
    } catch (e) {
      return Failure(e);
    }
  }

  Task<R> map<R>(R Function(T v) f) => Task(
    () => _run().then((r) => r.map(f)),
  );

  Task<R> flatMap<R>(FutureOr<Result<R>> Function(T v) f) => Task(
    () => _run().then((r) => r.flatMap(f)),
  );

  Task<T> tapSuccess(void Function(T v) f) => Task(
    () => _run().then((r) => r.tapSuccess(f)),
  );

  Task<T> tapFailure(void Function(Failure<T> failure) f) => Task(
    () => _run().then((r) => r.tapFailure(f)),
  );
}


extension FutureToTask<T> on Future<T> {
  Task<T> toTask() => Task(() => run());
}


extension PickTask on Task<String> {

  Task<Pick> pick([
    Object? arg0,
    Object? arg1,
    Object? arg2,
    Object? arg3,
    Object? arg4,
    Object? arg5,
    Object? arg6,
    Object? arg7,
    Object? arg8,
    Object? arg9,
  ]) {
    return Task(
      () => _run().then((r) {
        return r.pick(
          arg0,
          arg1,
          arg2,
          arg3,
          arg4,
          arg5,
          arg6,
          arg7,
          arg8,
          arg9,
        );
      }),
    );
  }
}


extension PickTaskAs on Task<Pick> {

  Task<List<T>> asListOrThrow<T>(T Function(RequiredPick) map, {
    T Function(Pick pick)? whenNull,
  }) {
    return Task(
      () => _run().then((r) => r.asListOrThrow(map, whenNull: whenNull)),
    );
  }

  Task<Map<K, V>> asMapOrThrow<K, V>() {
    return Task(
      () => _run().then((r) => r.asMapOrThrow<K, V>()),
    );
  }
}
