/// This file contains models widely used across the app
///
/// For the sake of testing `entities.dart` contains only
/// the internal Dart business logic, free from any Flutter
/// dependencies or side effects
///
/// All interface-related functionality has been decoupled and
/// moved to a dedicated `entities_ext.dart` file
///
/// This way we can test API requests or parser functions by
/// running `hydrus.dart`, `parser.dart`, etc. as console
/// applications
library;


class HydrusImage {
  final int id;
  double width = -1;
  double height = -1;
  late int size;
  late String type;
  late String ext;
  late int duration;
  late Map<String, TagService> service;

  int get length => service.values.first.entries.length;
  String get res => '${width.toStringAsFixed(0)}x${height.toStringAsFixed(0)}';

  set mime(String value) {
    final m = value.split('/');
    type = m.first;
    ext = m.last;
  }

  HydrusImage(this.id);
}


/// Contains information about a hydrus tag
/// - [raw] - "namespace:tag"
/// - [count] - (optional) useful for presenting the
/// number of entries in search
///
/// Getters:
/// - [namespace]
/// - [value]
///
/// [TagUi] extension getters:
/// - [color]
/// - [label] - Text widget with namespace [color]
///
/// UI features of this class is presented in
/// [TagUI] extension
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

  @override
  String toString() => raw;
}


class TagService {
  final String service;
  final List<Tag> entries;

  TagService({required this.service, required this.entries});

  @override
  String toString() {
    return 'service: $service, entries: $entries';
  }
}