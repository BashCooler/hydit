import 'package:dio/dio.dart';
import 'package:pub_semver/pub_semver.dart' as sv;
import 'package:package_info_plus/package_info_plus.dart';

import 'package:hydit/services/executor.dart';


class Version {
  const Version._();

  static const _apiUrl =
      'https://api.github.com/repos/OwlCarousel2/OwlCarousel2/releases/latest';

  /// Current version of Hydit.
  static Future<String> current() =>
      PackageInfo.fromPlatform().then((i) => i.version);

  static Future<Result<Release>> checkForUpdates() async {
    final dio = Dio();

    final map = await dio.get<Map<String, dynamic>>(_apiUrl)
        .run()
        .unwrap()
        .then((r) => r?.data);

    if (map == null) {
      return Failure('Connection error', 'Failed to get update info');
    }

    final cur = sv.Version.parse(await current());

    final versionString = map['tag_name'].replaceFirst('v', '');
    final available = sv.Version.parse(versionString);

    final update = cur < available;

    final release = Release(
      tag: available.canonicalizedVersion,
      url: map['html_url'],
      update: update,
    );

    return Success(release);
  }
}


class Release {
  final String tag;
  final String url;
  final bool update;

  Release({
    required this.tag,
    required this.url,
    required this.update,
  });
}
