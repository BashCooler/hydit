import 'package:flutter/services.dart';

import 'package:hydit/api/models.dart';
import 'package:hydit/services/executor.dart';


class const Native._() {

  static const _channel = MethodChannel("com.bashcooler.hydit/native");

  /// Save a string to a local SharedPreferences.
  static Future<Result<void>> savePreferences(String url, String key) {
    final arguments = {
      "url": url,
      "key": key,
    };
    return _channel
        .invokeMethod("saveSettings", arguments)
        .run();
  }

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
