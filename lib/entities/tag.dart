import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:hydit/utils/theme.dart';


class Tag extends Equatable {
  final String raw;
  final String? namespace;
  final String value;
  final String pretty;
  final int count;

  Color get color => colorOf(namespace);

  Tag(this.raw, {this.count = 0})
      : namespace = _namespace(raw),
        value = _value(raw),
        pretty = _pretty(raw);

  Tag.parse(this.raw)
      : count = 0,
        namespace = _namespace(raw),
        value = _value(raw),
        pretty = _pretty(raw);

  String? get ns => namespace;

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
    final pattern = RegExp('^(${namespaces.join('|')}):');
    return raw.replaceFirst(pattern, '').trim();
  }

  @override
  String toString() => raw;

  @override
  List<Object?> get props => [raw];
}


extension IterableOperations on Iterable<Tag> {
  List<String> rawList() => map((t) => t.raw).toList();
}


extension ToTags on List<String> {
  Iterable<Tag> toTags() => map((t) => Tag(t));
}


extension Sorting on Iterable<Tag> {
  TagSortBuilder sortBuilder() => TagSortBuilder(this);
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

  /// Tags with namespace first, then tags
  /// without namespace
  TagSortBuilder namespace() {
    _comparators.add((a, b) {
      final aNs = a.ns != null;
      final bNs = b.ns != null;

      if (aNs && !bNs) return -1;
      if (!aNs && bNs) return 1;

      return 0;
    });
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
  List<Tag> sort() {
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
