import 'package:hydit/services/executor.dart';


enum UrlErrorCode {
  protocolEmpty,
  urlInvalid,
  portInvalid,
  hostEmpty,
  pathNotEmpty,
}


extension ToFailure on UrlErrorCode {
  Failure<T> toFailure<T>() => Failure(
    switch (this) {
      .pathNotEmpty => 'Unsupported',
      _ => 'Input error',
    },
    switch (this) {
      .protocolEmpty => 'URL must start with "http://" or "https://"',
      .urlInvalid => 'Invalid URL',
      .portInvalid => 'Invalid port',
      .hostEmpty => 'Host is empty',
      .pathNotEmpty => 'URL path must be empty',
    },
  );
}


Result<Uri> parseUrl(String url) {
  final uri = Uri.tryParse(url);

  final str = uri.toString();

  if (!str.startsWith('http://') && !str.startsWith('https://')) {
    return UrlErrorCode.protocolEmpty.toFailure();
  }

  if (uri == null) {
    return UrlErrorCode.urlInvalid.toFailure();
  }

  if (uri.hasPort && (uri.port > 65535 || uri.port < 0)) {
    return UrlErrorCode.portInvalid.toFailure();
  }

  if (uri.host.isEmpty) {
    return UrlErrorCode.hostEmpty.toFailure();
  }

  if (uri.path.isNotEmpty && uri.path != '/') {
    return UrlErrorCode.pathNotEmpty.toFailure();
  }

  return uri.toSuccess();
}
