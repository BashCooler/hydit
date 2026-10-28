import 'dart:async';

import 'extensions.dart';


sealed class Result<T> {
  const Result();

  T? getOrNull();

  T getOrThrow();

  Result<T> tapSuccess(void Function(T v) f);

  Result<T> tapFailure(void Function(Object e) f);

  Result<R> map<R>(R Function(T v) f);

  Future<Result<R>> flatMap<R>(FutureOr<Result<R>> Function(T v) f);
}


class Success<T> extends Result<T> {
  final T v;

  const Success(this.v);

  @override
  T? getOrNull() => v;

  @override
  T getOrThrow() => v;

  @override
  Result<T> tapSuccess(void Function(T v) f) {
    f(v);
    return this;
  }

  @override
  Result<T> tapFailure(void Function(Object e) f) => this;

  @override
  Result<R> map<R>(R Function(T v) f) => f(v).toSuccess();

  @override
  Future<Result<R>> flatMap<R>(FutureOr<Result<R>> Function(T v) f) async {
    return await f(v);
  }
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
  Result<T> tapSuccess(void Function(T v) f) {
    return this;
  }

  @override
  Result<T> tapFailure(void Function(Object e) f) {
    f(this);
    return this;
  }

  @override
  Result<R> map<R>(R Function(T v) f) {
    return Failure<R>.from(this);
  }

  @override
  Future<Result<R>> flatMap<R>(FutureOr<Result<R>> Function(T v) f) async {
    return Failure<R>.from(this);
  }
}
