import 'package:hydit/entities/tag.dart';
import 'package:hydit/utils/collection.dart';


class TagService extends DelegatingSetBase<Tag> {
  final String name;
  final String key;
  final int type;

  final Set<Tag> entries;

  @override
  Set<Tag> get delegate => entries;

  bool get editable => type == 5;

  TagService({
    required this.name,
    required this.key,
    required this.type,
    required Set<Tag> initial,
  })
      : entries = Set.unmodifiable(initial);
}
