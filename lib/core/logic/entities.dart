import 'dart:ui';
import 'package:hydrus_flutter/utils/theme.dart';


class HydrusImage {
  final int id;
  int? width, height;
  String? mime;
  int? duration;
  Map<String, dynamic>? tags;

  HydrusImage(this.id);
}


class Tag {
  final String raw;
  final int? count;

  const Tag(this.raw, {this.count});

  String get namespace {
    final idx = raw.indexOf(':');
    return idx == -1 ? 'no namespace' : raw.substring(0 , idx);
  }

  String get value {
    final idx = raw.indexOf(':');
    return idx == -1 ? raw : raw.substring(idx + 1);
  }

  Color? get color =>
      namespaceColors[namespace] ?? namespaceColors['namespace'];
}