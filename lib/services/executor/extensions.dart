import 'dart:async';

import 'result.dart';


extension ToResult<T> on T {
  Success<T> toSuccess() => Success(this);
}


extension IterableResult<T> on Result<Iterable<T>> {
  Result<Iterable<R>> mapElements<R>(R Function(T v) toElement) =>
      map((i) => i.map(toElement));

  Result<List<T>> toList() => map((i) => i.toList());
}


extension AsyncIterableResult<T> on Future<Result<Iterable<T>>> {
  Future<Result<Iterable<R>>> mapElements<R>(R Function(T v) toElement) =>
      then((r) => r.mapElements(toElement));

  Future<Result<List<T>>> toList() => then((r) => r.toList());
}


extension AsyncResult<T> on Future<Result<T>> {

  Future<T?> getOrNull() => then((r) => r.getOrNull());

  Future<T> getOrThrow() => then((r) => r.getOrThrow());

  Future<Result<R>> map<R>(R Function(T data) f) => then((r) => r.map(f));

  Future<Result<R>> flatMap<R>(FutureOr<Result<R>> Function(T v) f) =>
      then((r) => r.flatMap(f));

  Future<Result<T>> tapSuccess(FutureOr<void> Function(T data) f) =>
      then((r) => r.tapSuccess(f));

  Future<Result<T>> tapFailure(FutureOr<void> Function(Failure<T> failure) f) =>
      then((r) => r.tapFailure(f));
}
