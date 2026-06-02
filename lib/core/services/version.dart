import 'package:dio/dio.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:package_info_plus/package_info_plus.dart';


const downloadUrl =
    'https://github.com/BashCooler/hydit/releases/latest';
const apiUrl =
    'https://api.github.com/repos/OwlCarousel2/OwlCarousel2/releases/latest';


Future<String?> getUpdateVersion() async {
  final current = await version();
  final latest = await getLatestVersion();

  if (latest == null) return null;
  switch (Version.parse(latest) > Version.parse(current)) {
    case true:
      return latest;
    case false:
      return null;
  }
}


Future<String> version() async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
}


Future<String?> getLatestVersion() async {
  final dio = Dio();

  final Response<Map<String, dynamic>> response;
  try {
    response = await dio.get<Map<String, dynamic>>(apiUrl);
  } catch (e) {
    return null;
  }

  final Map<String, dynamic>? result = response.data;
  final String? version = result?['tag_name']?.replaceFirst('v', '');

  return version;
}
