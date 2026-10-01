import 'package:deep_pick/deep_pick.dart';

import 'package:hydit/api/enums.dart';
import 'package:hydit/utils/utils.dart';
import 'package:hydit/entities/tag.dart';


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
    required this.entries,
  });

  factory TagService.fromMapEntry(MapEntry<String, dynamic> entry, {
    required TagDisplayType type,
  }) {
    return TagService(
      name: entry.value['name'],
      key: entry.key,
      type: entry.value['type'],
      entries: pick(entry.value, '$type', '0')
          .asListOrEmpty((t) => t.asStringOrThrow())
          .map(Tag.new)
          .let(TagSortBuilder.new)
          .namespace()
          .alphabetical()
          .sort()
          .toSet(),
    );
  }
}
