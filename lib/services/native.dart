import 'package:flutter/services.dart';

import 'package:hydit/api/models.dart';


class const Native._() {

  static const _channel = MethodChannel("com.bashcooler.hydit/native");

  /// Save a string to a local SharedPreferences.
  ///
  /// /// Throws [PlatformException].
  static Future<void> savePreferences(String url, String key) =>
      _channel.invokeMethod(
        "saveSettings",
        {
          "url": url,
          "key": key,
        },
      );

  /// Save file to local downloads folder.
  ///
  /// Will only work on Android 10+.
  ///
  /// Throws [PlatformException].
  static Future<void> saveFile(PendingFile file) =>
      _channel.invokeMethod(
        "saveFile",
        {
          "bytes": file.bytes,
          "name": file.name,
          "type": file.mime,
        },
      );
}
