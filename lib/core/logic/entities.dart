import 'dart:typed_data';


class HydrusImage {
  final int id;
  Uint8List? low;
  Uint8List? high;
  int? width, height;
  String? mime;
  int? duration;
  Map<String, dynamic>? tags;

  HydrusImage(this.id);
}


class Tag {
  final String raw;
  const Tag(this.raw);

  String get namespace {
    final idx = raw.indexOf(':');
    return idx == -1 ? 'no namespace' : raw.substring(0 , idx);
  }

  String get value {
    final idx = raw.indexOf(':');
    return idx == -1 ? raw : raw.substring(idx + 1);
  }
}