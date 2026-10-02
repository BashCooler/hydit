import 'package:deep_pick/deep_pick.dart';

import 'package:hydit/api/enums.dart';
import 'package:hydit/utils/utils.dart';
import 'package:hydit/utils/tag_sort.dart';
import 'package:hydit/entities/tag.dart';


class const TagService({
  required final String name,
  required final String key,
  required final int type,
  required final Set<Tag> entries,
}) extends DelegatingSetBase<Tag> {

  @override
  Set<Tag> get delegate => entries;

  bool get editable => type == 5;

  factory fromMapEntry(MapEntry<String, dynamic> entry, {
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
