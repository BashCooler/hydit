import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:hydit/utils/theme.dart';


class Tag extends Equatable {
  final String? service;
  final String raw;
  final String? namespace;
  final String value;
  final String pretty;
  final int? count;
  late final Color color;

  Tag(this.raw, {this.service, this.count})
      : namespace = _namespace(raw),
        value = _value(raw),
        pretty = _pretty(raw),
        color = colorOf(_namespace(raw));

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
}


extension RawList on Iterable<Tag> {
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
