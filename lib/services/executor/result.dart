import 'dart:async';


sealed class Result<T> {
  const Result();

  T? getOrNull();

  T getOrThrow();

  Result<T> tapSuccess(void Function(T data) f);

  Result<T> tapFailure(void Function(Object e) f);

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
  Result<T> tapFailure(void Function(Object e) f) => this;

  @override
  Result<R> map<R>(R Function(T data) f) => Success(f(data));

  @override
  Future<Result<R>> flatMap<R>(FutureOr<Result<R>> Function(T data) f) async {
    return await f(data);
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
  Result<T> tapSuccess(void Function(T data) f) {
    return this;
  }

  @override
  Result<T> tapFailure(void Function(Object e) f) {
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
