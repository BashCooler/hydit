import 'package:hydit/utils/errors.dart';
import 'package:hydit/services/executor.dart';


extension ValidateUrl on String {
  /// Check if this URL is a valid Hydrus url.
  Result<String> validateUrl() {
    //
    final uri = Uri.tryParse(this);

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

    final str = uri.replace(path: '').toString();

    if (!str.startsWith('http://') && !str.startsWith('https://')) {
      return UrlErrorCode.protocolEmpty.toFailure();
    }

    return str.toSuccess();
  }
}
