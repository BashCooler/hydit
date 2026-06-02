/// Object representing settings structure.
///
/// You can make this object observable to
/// perform reactive updates on parameter
/// change.
class AppSettings {
  String url = '';
  String key = '';

  AppSettings({required this.url, required this.key});

  /// Changing [AppSettings] value with this method
  /// ensures UI updates are working fine.
  ///
  /// Returns new [AppSettings] object with applied
  /// changes.
  AppSettings copyWith({String? url, String? key}) {
    return AppSettings(
      url: url ?? this.url,
      key: key ?? this.key,
    );
  }
}