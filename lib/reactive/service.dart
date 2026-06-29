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
