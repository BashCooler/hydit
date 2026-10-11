import 'package:dart_mappable/dart_mappable.dart';

import 'package:hydit/entities/tag.dart';

part 'models.mapper.dart';


@MappableClass()
class const SiblingsAndParentsDto({
  /// Tag -> service key -> relations
  required final Map<Tag, Map<String, TagRelations>> tags,
}) with SiblingsAndParentsDtoMappable {
  static final fromMap = SiblingsAndParentsDtoMapper.fromMap;
  static final fromJson = SiblingsAndParentsDtoMapper.fromJson;
}


class const TagMapper() extends SimpleMapper<Tag> {
  @override
  Tag decode(dynamic value) => Tag(value as String);

  @override
  String encode(Tag self) => self.raw;
}


@MappableClass(
  includeCustomMappers: [
    TagMapper(),
  ],
)
class TagRelations({
  @MappableField(key: 'ideal_tag')
  required final Tag ideal,
  required final List<Tag> ancestors,
}) with TagRelationsMappable {
  static final fromMap = TagRelationsMapper.fromMap;
  static final fromJson = TagRelationsMapper.fromJson;
}
