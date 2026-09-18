library;

import 'package:hydit/services/executor.dart';


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
}


class Failure<T> extends Result<T> {
  final String title;
  final String message;

  const Failure(this.title, this.message);

  factory Failure.from(Failure failure) => Failure(
    failure.title,
    failure.message,
  );

  @override
  String toString() => '$title: $message';

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
  Result<R> map<R>(R Function(T data) f) => Failure<R>.from(this);
}
