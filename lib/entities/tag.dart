import 'package:flutter/services.dart';
import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

import 'package:hydit/utils/utils.dart';


class Tag extends Equatable {
  final String raw;
  final int count;

  late final int idx = raw.indexOf(':');

  late final String value = idx
      .let((it) => it == -1 ? raw : raw.substring(it + 1));

  late final String? namespace = idx
      .let((it) => it == -1 ? null : raw.substring(0, it));

  late final String pretty = raw.replaceFirst(_pattern, '').trim();

  Tag(this.raw, {this.count = 0});

  Color get color => colorOf(namespace);

  /// The [map] parameter should be extracted from `search_tags`
  /// response like so:
  ///
  /// `json -> tags -> 0` (or other index)
  factory Tag.fromMap(Map<String, dynamic> map) =>
      Tag(map['value'], count: map['count']);

  /// The [pick] parameter should be extracted from `search_tags`
  /// response like so:
  ///
  /// `pick(json, 'tags', 0)` (or other index)
  factory Tag.fromPick(Pick pick) {
    final map = pick.asMapOrThrow<String, dynamic>();

    return Tag.fromMap(map);
  }

  static const Set<String> namespaces = {
    'system',
    'creator',
    'character',
    'meta',
    'series',
    'studio',
  };

  static final _pattern = RegExp('^(${namespaces.join('|')}):');

  @override
  String toString() => raw;

  @override
  List<Object?> get props => [raw];

  static void toClipboard(Tag t) =>
      Clipboard.setData(ClipboardData(text: t.raw));
}


extension IterableTagExtension on Iterable<Tag> {
  List<String> rawList() => map((t) => t.raw).toList();
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
      final aNs = a.namespace != null;
      final bNs = b.namespace != null;

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
