part of 'executor.dart';


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


sealed class Result<T> {

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

  Success(this.data);
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

  Failure(this.title, this.message, [this.details]);

  @override
  String toString() => '$title: $message';
}
