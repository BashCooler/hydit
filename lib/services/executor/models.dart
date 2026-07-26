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


class _Unit {
  const _Unit._();
}

const unit = _Unit._();


sealed class Result<T> {
  const Result();

  T? unwrap() {
    if (this case Success(data: final data)) {
      return data;
    }
    return null;
  }

  T unwrapOrThrow() {
    if (this case Success(data: final data)) {
      return data;
    }
    throw StateError('An attempt to unwrap a Failure');
  }
}

class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);
}


class FailureBuilder<T> {
  String title = 'Error';
  String message = 'Unknown error';
  Object? details;

  Failure<T> build() => Failure<T>(title, message);

  Failure<T> call() => build();
}


class Failure<T> extends Result<T> {
  final String title;
  final String message;
  final Object? details;

  const Failure(this.title, this.message, [
    this.details,
  ]);

  factory Failure.from(Failure failure) => Failure(
    failure.title,
    failure.message,
    failure.details,
  );

  @override
  String toString() => '$title: $message';
}
