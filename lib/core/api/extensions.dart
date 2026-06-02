

extension ListStringUnicodeEscape on List<String> {
  String encode() {
    final encoded = map((t) => '"${t.encode()}"').toList();
    final jsonString = '[${encoded.join(", ")}]';
    return Uri.encodeComponent(jsonString);
  }
}

extension StringUnicodeEscape on String {
  static RegExp p = RegExp(r'[^\x00-\x7F]');

  String encode() => replaceAllMapped(p, (m) => '\\u${m.encode()}');
}

extension MatchUnicodeEscape on Match {
  // ignore: unnecessary_this
  String encode() => this
      .group(0)!
      .codeUnitAt(0)
      .toRadixString(16)
      .padLeft(4, '0');
}