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
/// running `api.dart`, `mapper.dart`, etc. as console
/// applications
library;

import 'package:get/get.dart';
import 'package:filesize/filesize.dart';
import 'package:equatable/equatable.dart';

import '../data/repo.dart';


class HydrusFile {
  final int id;
  final metadata = Rxn<FileMetadata>();

  HydrusFile({required this.id});

  bool get loaded => metadata.value != null;
  bool get loading => metadata.value == null;

  Future<void> forceLoadMetadata() async {
    final Repo repo = Get.find();
    await repo.setMetadataFor(this);
  }

  FileMetadata? get meta => metadata.value;
}


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


class Tag extends Equatable {
  final String? service;
  final String raw;
  final String? namespace;
  final String value;
  final String pretty;
  final int? count;

  Tag(this.raw, {this.service, this.count})
      : namespace = _namespace(raw),
        value = _value(raw),
        pretty = _pretty(raw);

  Tag copyWith({String? service, int? count}) {
    return Tag(
      raw,
      service: service ?? this.service,
      count: count ?? this.count,
    );
  }

  static String? _namespace(String raw) {
    final idx = raw.indexOf(':');
    return idx == -1 ? null : raw.substring(0 , idx);
  }

  static String _value(String raw) {
    final idx = raw.indexOf(':');
    return idx == -1 ? raw : raw.substring(idx + 1);
  }

  static const Set<String> namespaces = {
    'system',
    'creator',
    'character',
    'meta',
    'series',
    'studio',
  };

  static String _pretty(String raw) {
    final idx = raw.indexOf(':');
    if (idx == -1) return raw;
    final namespace = raw.substring(0 , idx);
    if (namespaces.contains(namespace)) return _value(raw);
    return raw;
  }

  @override
  String toString() => '"$service": "$raw"';

  @override
  List<Object?> get props => [raw, service];
}


extension TagOperations on Set<Tag> {
  Set<Tag> operator [](String service) {
    return Set.unmodifiable(where((e) => e.service == service));
  }

  Set<String> get services {
    return map((t) => t.service).whereType<String>().toSet();
  }

  List<String> get rawList => map((t) => t.raw).toList();
}


extension Sorting on Iterable<Tag> {
  TagSortBuilder get sort => TagSortBuilder(this);
}


class TagSortBuilder {
  final Iterable<Tag> _tags;

  final List<Comparator<Tag>> _comparators = [];

  TagSortBuilder(this._tags);

  /// Sort tags in alphabetical order
  TagSortBuilder alphabetical() {
    _comparators.add((a, b) => a.raw.compareTo(b.raw));
    return this;
  }

  /// Sort tags by state: added tags first,
  /// then removed or unchanged
  TagSortBuilder state(Set<Tag> original) {
    _comparators.add((a, b) {
      final aAdded = !original.contains(a);
      final bAdded = !original.contains(b);

      if (aAdded == bAdded) return 0;

      return aAdded ? -1 : 1;
    });
    return this;
  }

  /// Apply all sorting operations and return
  /// a [List] of [Tag]s
  List<Tag> build() {
    final list = _tags.toList();

    list.sort((a, b) {
      for (final compare in _comparators) {
        final result = compare(a, b);
        if (result != 0) return result;
      }
      return 0;
    });

    return list;
  }
}
