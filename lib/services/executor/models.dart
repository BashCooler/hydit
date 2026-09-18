library;


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
}

class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  T? getOrNull() => data;

  @override
  T getOrThrow() => data;
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
}
