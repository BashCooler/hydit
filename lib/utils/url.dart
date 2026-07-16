import 'package:hydit/services/executor.dart';


Result<Uri> isValidUrl(String url) {
  final uri = Uri.tryParse(url);

  if (uri == null) {
    return Failure('Input error', 'Invalid URL');
  }

  final str = uri.toString();

  if (!str.startsWith('http://') && !str.startsWith('https://')) {

    final result = FailureBuilder<Uri>()
      ..title = 'Input error'
      ..message = 'URL should start with "http://" or "https://"';

    return result();
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

  return Success(uri);
}
