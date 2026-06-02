import 'package:filesize/filesize.dart';

import 'tag.dart';


class FileMetadata {
  final double width;
  final double height;
  final int _size;
  final String type;
  final String ext;
  final Duration duration;

  /// This [Set] contains all tags from all services, which means
  /// it may have duplicate tags from different services, so don't
  /// show it in UI.
  final Set<Tag> combined;

  late final Map<String, List<String>> namespaces;

  FileMetadata({
    required this.width,
    required this.height,
    required this._size,
    required String mime,
    required int duration,
    required this.combined,
  }) : type = mime.split('/').first,
        ext = mime.split('/').last,
        duration = Duration(milliseconds: duration) {
    namespaces = buildNamespaceIndex(combined);
  }

  String get size => filesize(_size);
  String get res => '${width.toStringAsFixed(0)}x${height.toStringAsFixed(0)}';

  /// Tags from `all known tags` service as [Iterable]
  Iterable<Tag> get all => combined
      .where((e) => e.service == 'all known tags');

  /// Length of `all known tags` service
  int get length => combined
      .where((e) => e.service == 'all known tags')
      .length;

  static Map<String, List<String>> buildNamespaceIndex(Set<Tag> combined) {
    final map = <String, List<String>>{};

    for (final tag in combined) {
      if (tag.namespace == null) continue;
      map.putIfAbsent(tag.namespace!, () => []).add(tag.value);
    }

    for (final values in map.values) {
      values.sort();
    }

    return map;
  }
}