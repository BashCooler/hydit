import 'package:hydit/entities/tag.dart';


class TagService {
  final String name;
  final String key;
  final int type;

  final Set<Tag> initial;

  bool get editable => type == 5;

  TagService({
    required this.name,
    required this.key,
    required this.type,
    required Set<Tag> initial,
  })
      : initial = Set.unmodifiable(initial);
}


class TagDiff {
  final String key;
  final Set<Tag> _added;
  final Set<Tag> _deleted;

  TagDiff({
    required this.key,
    required this._added,
    required this._deleted,
  });

  bool get isNotEmpty => _added.isNotEmpty || _deleted.isNotEmpty;

  Map<String, List<String>> get value =>
      {
        "0": _added.rawList(),
        "1": _deleted.rawList(),
      };
}
