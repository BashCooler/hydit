import 'package:dio/dio.dart';
import 'package:pub_semver/pub_semver.dart' as sv;
import 'package:package_info_plus/package_info_plus.dart';


class Version {
  Version._();

  static const _releases =
      'https://github.com/BashCooler/hydit/releases/latest';

  static const _apiUrl =
      'https://api.github.com/repos/OwlCarousel2/OwlCarousel2/releases/latest';

  static Uri get updateUrl => Uri.parse(_releases);

  /// Latest version of Hydit available.
  ///
  /// Returns null if current version matches latest
  static Future<String?> update() async {
    final c = await current();
    final l = await latest();

    if (l == null) return null;

    final update = sv.Version.parse(l) > sv.Version.parse(c);
    if (!update) return null;

    return l;
  }

  static Future<String> current() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  static Future<String?> latest() async {
    final dio = Dio();

    final Response<Map<String, dynamic>> response;
    try {
      response = await dio.get<Map<String, dynamic>>(_apiUrl);
    } catch (e) {
      return null;
    }

    final Map<String, dynamic>? result = response.data;
    final String? version = result?['tag_name']?.replaceFirst('v', '');

    return version;
  }
}
