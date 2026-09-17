import 'package:hydit/services/executor.dart';


Result<Uri> parseUrl(String url) {
  final uri = Uri.tryParse(url);

  final str = uri.toString();

  if (!str.startsWith('http://') && !str.startsWith('https://')) {
    return Failure(
      'Input error',
      'URL must start with "http://" or "https://"',
    );
  }

  if (uri == null) {
    return Failure('Input error', 'Invalid URL');
  }

  if (uri.hasPort && (uri.port > 65535 || uri.port < 0)) {
    return Failure('Input error', 'Invalid port');
  }

  if (uri.host.isEmpty) {
    return Failure('Input error', 'Host is empty');
  }

  if (uri.path.isNotEmpty && uri.path != '/') {
    return Failure('Unsupported', 'URL path must be empty');
  }

  return Success(uri);
}
