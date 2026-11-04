import 'package:hydit/utils/errors.dart';


/// Check if this URL is a valid Hydrus url.
///
/// Throws [UrlError].
String validateUrl(String url) {
  //
  final uri = Uri.tryParse(url);

  if (uri == null) {
    throw UrlErrorCode.urlInvalid.toError();
  }

  if (uri.hasPort && (uri.port > 65535 || uri.port < 0)) {
    throw UrlErrorCode.portInvalid.toError();
  }

  if (uri.host.isEmpty) {
    throw UrlErrorCode.hostEmpty.toError();
  }

  if (uri.path.isNotEmpty && uri.path != '/') {
    throw UrlErrorCode.pathNotEmpty.toError();
  }

  final str = uri.replace(path: '').toString();

  if (!str.startsWith('http://') && !str.startsWith('https://')) {
    throw UrlErrorCode.protocolEmpty.toError();
  }

  return str;
}
