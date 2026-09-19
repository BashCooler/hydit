import 'package:hydit/services/executor.dart';


sealed class AppError implements Exception {
  const AppError();
}


enum UrlErrorCode {
  protocolEmpty,
  urlInvalid,
  portInvalid,
  hostEmpty,
  pathNotEmpty;

  UrlError toError() => UrlError(this);

  Failure<T> toFailure<T>() => toError().toFailure();
}


final class UrlError extends AppError {
  final UrlErrorCode code;

  const UrlError(this.code);

  String get title => switch (code) {
    .pathNotEmpty => 'Unsupported',
    _ => 'Input error',
  };

  String get message => switch (code) {
    .protocolEmpty => 'URL must start with "http://" or "https://"',
    .urlInvalid => 'Invalid URL',
    .portInvalid => 'Invalid port',
    .hostEmpty => 'Host is empty',
    .pathNotEmpty => 'URL path must be empty',
  };

  Failure<T> toFailure<T>() => Failure<T>(title, message);
}
