import 'package:hydit/utils/errors.dart';
import 'package:hydit/services/executor.dart';


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
