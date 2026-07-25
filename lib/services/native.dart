import 'package:flutter/services.dart';
import 'package:hydit/services/executor.dart';


class Native {
  Native._();

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
  static Future<Result<void>> saveFile(
      Uint8List bytes,
      String fileName,
      String mimeType,
  ) {
    final arguments = {
      "bytes": bytes,
      "fileName": fileName,
      "mimeType": mimeType,
    };
    return _channel
        .invokeListMethod("saveFile", arguments)
        .run();
  }
}
