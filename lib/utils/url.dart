import 'package:hydit/services/executor.dart';


Result<Uri> parseUrl(String url) {
  final uri = Uri.tryParse(url);

  final str = uri.toString();

  if (!str.startsWith('http://') && !str.startsWith('https://')) {

    final result = FailureBuilder<Uri>()
      ..title = 'Input error'
      ..message = 'URL must start with "http://" or "https://"';

    return result();
  }

  if (uri == null) {
    return Failure('Input error', 'Invalid URL');
  }

  if (uri.hasPort && (uri.port > 65535 || uri.port < 0)) {
    return Failure('Input error', 'Invalid port');
  }

  if (uri.host.isEmpty) {

    final result = FailureBuilder<Uri>()
      ..title = 'Input error'
      ..message = 'Host is empty';

    return result();
  }

  if (uri.path.isNotEmpty && uri.path != '/') {

    final result = FailureBuilder<Uri>()
      ..title = 'Unsupported'
      ..message = 'URL path must be empty';

    return result();
  }

  return Success(uri);
}
