import 'package:dio/dio.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/utils/errors.dart';
import 'package:hydit/services/executor.dart';


class const UpdateService._() {

  static const apiUrl =
      'https://api.github.com/repos/BashCooler/hydit/releases/latest';

  /// Current version of Hydit.
  static Future<String> current() =>
      PackageInfo.fromPlatform().then((i) => i.version);

  /// Latest version of Hydit from GitHub.
  static Future<Result<Release>> latestRelease() async {

    final origin = await Dio().get<Map<String, dynamic>>(apiUrl)
        .run()
        .map(Release.fromResponse)
        .getOrNull();

    if (origin == null) {
      return CustomError('Connection error', 'Failed to get update info')
          .toFailure();
    }

    final app = await current().then(Release.parse);

    if (app < origin) {
      return origin.asUpdate().toSuccess();
    }

    return origin.toSuccess();
  }
}


class const Release(final Version version, {
  final String? httpUrl,
  final bool isUpdate = false,
}) {
  bool operator <(Release other) => version < other.version;

  factory fromResponse(Response<Map<String, dynamic>> m) =>
      Release.fromMap(m.data!);

  factory fromMap(Map<String, dynamic> m) => Release.parse(
      m['tag_name'],
      httpUrl: m['html_url'],
  );

  factory parse(String tagName, {
    String? httpUrl,
  }) {
    return Release(
      tagName.replaceFirst('v', '').let(Version.parse),
      httpUrl: httpUrl,
    );
  }

  Release asUpdate() => Release(version, httpUrl: httpUrl, isUpdate: true);
}
