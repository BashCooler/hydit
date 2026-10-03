import 'package:deep_pick/deep_pick.dart';
import 'package:hydit/api/models.dart';

import 'package:hydit/entities/tag.dart';
import 'package:hydit/utils/tag_sort.dart';


class const TagService({
  required final String name,
  required final String key,
  required final int type,
  required final Set<Tag> storage,
  required final Set<Tag> display,
}) {

  bool get editable => type == 5;

  factory fromMapEntry(MapEntry<String, dynamic> entry) {
    return TagService(
      name: entry.value['name'],
      key: entry.key,
      type: entry.value['type'],
      storage: pick(entry.value, 'storage_tags', '0')
          .asListOrEmpty((t) => t.asStringOrThrow())
          .map(Tag.new)
          .sortNamespaceAlphabeticalToSet(),
      display: pick(entry.value, 'display_tags', '0')
          .asListOrEmpty((t) => t.asStringOrThrow())
          .map(Tag.new)
          .sortNamespaceAlphabeticalToSet()
    );
  }

  factory fromDto(MapEntry<String, TagServiceDto> dto) => TagService(
    name: dto.value.name,
    key: dto.key,
    type: dto.value.type,
    storage: dto.value.storageTags['0']!.map(Tag.new)
        .sortNamespaceAlphabeticalToSet(),
    display: dto.value.displayTags['0']!.map(Tag.new)
        .sortNamespaceAlphabeticalToSet(),
  );
}


extension SortToSet on Iterable<Tag> {
  Set<Tag> sortNamespaceAlphabeticalToSet() => TagSortBuilder(this)
      .namespace()
      .alphabetical()
      .sort()
      .toSet();
}
