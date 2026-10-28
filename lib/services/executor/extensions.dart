import 'dart:async';

import 'result.dart';


extension ToSuccess<T> on T {
  Success<T> toSuccess() => Success(this);
}


extension MapElements<T> on Result<Iterable<T>> {
  Result<List<R>> mapElements<R>(R Function(T v) toElement) =>
      map((i) => i.map(toElement).toList());
}


extension AsyncMapElements<T> on Future<Result<Iterable<T>>> {
  Future<Result<List<R>>> mapElements<R>(R Function(T v) toElement) async =>
      (await this).mapElements(toElement);
}


extension AsyncOperations<T> on Future<Result<T>> {

  Future<T?> getOrNull() async => (await this).getOrNull();

  Future<T> getOrThrow() async => (await this).getOrThrow();

  Future<Result<R>> map<R>(R Function(T data) f) async {
    return (await this).map(f);
  }

  Future<Result<R>> flatMap<R>(FutureOr<Result<R>> Function(T v) f) async {
    return (await this).flatMap((r) => f(r));
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
