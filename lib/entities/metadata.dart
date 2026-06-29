import 'package:filesize/filesize.dart';

import 'tag.dart';


class FileMetadata {
  final double width;
  final double height;
  final int _size;
  final String mime;
  final Duration duration;

  /// This [Set] contains all tags from all services, which means
  /// it may have duplicate tags from different services, so don't
  /// show it in UI.
  final Map<String, Set<Tag>> combined;

  late final Map<String, List<String>> namespaces;

  FileMetadata({
    required this.width,
    required this.height,
    required this._size,
    required this.mime,
    required int duration,
    required this.combined,
  })
      : duration = Duration(milliseconds: duration) {
    namespaces = buildNamespaceIndex();
  }

  String get type => mime.split('/').first;
  String get size => filesize(_size);
  String get res => '${width.toStringAsFixed(0)}x${height.toStringAsFixed(0)}';

  /// Tags from `all known tags` service as [Iterable]
  Iterable<Tag> get all => combined['all known tags'] ?? [];

  /// Length of `all known tags` service
  int get length => all.length;

  Map<String, List<String>> buildNamespaceIndex() {
    final map = <String, List<String>>{};

    for (final tag in all) {
      if (tag.namespace == null) continue;
      map.putIfAbsent(tag.namespace!, () => []).add(tag.value);
    }

    for (final values in map.values) {
      values.sort();
    }

    return map;
  }
}
