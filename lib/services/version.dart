import 'package:dio/dio.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/utils/errors.dart';
import 'package:hydit/services/executor.dart';


class UpdateService {
  const UpdateService._();

  static const apiUrl =
      'https://api.github.com/repos/BashCooler/hydit/releases/latest';

  /// Current version of Hydit.
  static Future<String> current() =>
      PackageInfo.fromPlatform().then((i) => i.version);

  static Future<Result<Release>> latestRelease() async {

    final origin = await Dio().get<Map<String, dynamic>>(apiUrl)
        .toTask()
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


class Release {
  final Version version;
  final String? httpUrl;
  final bool isUpdate;

  Release(this.version, {this.httpUrl, this.isUpdate = false});

  bool operator <(Release other) => version < other.version;

  factory Release.fromResponse(Response<Map<String, dynamic>> m) =>
      Release.fromMap(m.data!);

  factory Release.fromMap(Map<String, dynamic> m) => Release.parse(
      m['tag_name'],
      httpUrl: m['html_url'],
  );

  factory Release.parse(String tagName, {
    String? httpUrl,
  }) {
    return Release(
      tagName.replaceFirst('v', '').let(Version.parse),
      httpUrl: httpUrl,
    );
  }

  Release asUpdate() => Release(version, httpUrl: httpUrl, isUpdate: true);
}
