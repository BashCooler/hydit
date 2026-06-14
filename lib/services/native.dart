import 'package:flutter/services.dart';


class Native {
  Native._();

  static const _channel = MethodChannel("com.bashcooler.hydit/native");

  static Future<void> saveSettings(String url, String key) async {
    final arguments = {
      "url": url,
      "key": key,
    };

    try {
      await _channel.invokeMethod("saveSettings", arguments);
    } on PlatformException catch (_) {
      rethrow;
    }
  }
}