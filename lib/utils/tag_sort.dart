import 'package:hydit/entities/tag.dart';


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
