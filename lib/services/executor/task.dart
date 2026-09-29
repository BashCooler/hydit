import 'dart:async';

import 'models.dart';
import 'executor.dart';


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
