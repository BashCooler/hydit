import 'package:dart_mappable/dart_mappable.dart';

part 'models.mapper.dart';


@MappableClass()
class const SiblingsAndParentsDto({
  /// Tag -> service key -> relations
  required final Map<String, Map<String, TagRelations>> tags,
}) with SiblingsAndParentsDtoMappable {
  static final fromMap = SiblingsAndParentsDtoMapper.fromMap;
  static final fromJson = SiblingsAndParentsDtoMapper.fromJson;
}


@MappableClass()
class TagRelations({
  @MappableField(key: 'ideal_tag')
  required final String ideal,
  required final List<String> descendants,
}) with TagRelationsMappable {
  static final fromMap = TagRelationsMapper.fromMap;
  static final fromJson = TagRelationsMapper.fromJson;
}
