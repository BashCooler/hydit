library;

import 'dart:async';

import 'package:hydit/utils/errors.dart';
import 'package:hydit/services/executor.dart';


class Task<T> {
  final Future<Result<T>> Function() _run;

  const Task(this._run);

  Future<Result<T>> run() async {
    try {
      return await _run();
    } catch (e) {
      return AppError.from(e).toFailure();
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


mixin class CancellationToken {
  bool _cancelled = false;

  bool get cancelled => _cancelled;

  void cancel() => _cancelled = true;
}


mixin class CompletionToken {
  bool _completed = false;

  bool get completed => _completed;

  void complete() => _completed = true;
}


class Token with CancellationToken, CompletionToken {
  @override
  bool get cancelled => _cancelled && !completed;
}


class Unit {
  const Unit._();
}

const unit = Unit._();


sealed class Result<T> {
  const Result();

  T? getOrNull();

  T getOrThrow();

  Result<T> tapSuccess(void Function(T data) f);

  Result<T> tapFailure(void Function(Failure<T> failure) f);

  Result<R> map<R>(R Function(T data) f);

  Future<Result<R>> flatMap<R>(FutureOr<Result<R>> Function(T data) f);
}

class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  T? getOrNull() => data;

  @override
  T getOrThrow() => data;

  @override
  Result<T> tapSuccess(void Function(T data) f) {
    f(data);
    return this;
  }

  @override
  Result<T> tapFailure(void Function(Failure<T> failure) f) {
    return this;
  }

  @override
  Result<R> map<R>(R Function(T data) f) => f(data).toSuccess();

  @override
  Future<Result<R>> flatMap<R>(FutureOr<Result<R>> Function(T data) f) async {
    return await f(data);
  }
}


extension ToSuccess<T> on T {
  Success<T> toSuccess() => Success(this);
}


class Failure<T> extends Result<T> {
  final Object e;

  const Failure(this.e);

  factory Failure.from(Failure failure) => Failure(failure.e);

  @override
  String toString() => e.toString();

  @override
  T? getOrNull() => null;

  @override
  T getOrThrow() {
    throw StateError('An attempt to unwrap a Failure');
  }

  @override
  Result<T> tapSuccess(void Function(T data) f) {
    return this;
  }

  @override
  Result<T> tapFailure(void Function(Failure<T> failure) f) {
    f(this);
    return this;
  }

  @override
  Result<R> map<R>(R Function(T data) f) {
    return Failure<R>.from(this);
  }

  @override
  Future<Result<R>> flatMap<R>(FutureOr<Result<R>> Function(T data) f) async {
    return Failure<R>.from(this);
  }
}


extension AsyncOperations<T> on Future<Result<T>> {

  Future<T?> getOrNull() async => (await this).getOrNull();

  Future<T> getOrThrow() async => (await this).getOrThrow();

  Future<Result<R>> map<R>(R Function(T data) f) async {
    return (await this).map(f);
  }

  Future<Result<T>> tapSuccess(
      FutureOr<void> Function(T data) f) async {

    return (await this).tapSuccess(f);
  }

  Future<Result<T>> tapFailure(
      FutureOr<void> Function(Failure<T> failure) f) async {

    return (await this).tapFailure(f);
  }
}
