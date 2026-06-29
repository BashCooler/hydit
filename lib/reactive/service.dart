import 'package:get/get.dart';
import 'package:hydit/entities/tag.dart';


class TagService {
  final String name;
  final String key;
  final int type;

  final Set<Tag> initial;
  final RxSet<Tag> current;

  bool get editable => type == 5;

  TagService({
    required this.name,
    required this.key,
    required this.type,
    required Set<Tag> initial,
  })
      : initial = Set.unmodifiable(initial),
        current = initial.obs;

  /// Tags added to this service
  Set<Tag> additions() => current.difference(initial);

  /// Tags deleted from this service
  Set<Tag> deletions() => initial.difference(current);

  /// Initial, added and deleted tags
  Set<Tag> union() => { ...initial, ...current };

  /// Sorted tags to show in UI
  List<Tag> tags() => current()
      .sortBuilder()
      .state(initial)
      .namespace()
      .alphabetical()
      .sort();

  /// Discard all changes
  void revert() => current.assignAll(initial);
}
