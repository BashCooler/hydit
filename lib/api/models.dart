@MappableLib(caseStyle: .snakeCase)
library;

import 'package:collection/collection.dart';
import 'package:dart_mappable/dart_mappable.dart';

import 'package:hydit/entities/tag.dart';
import 'package:hydit/utils/tag_sort.dart';

part 'models.mapper.dart';


class const TagMapper() extends SimpleMapper<Tag> {
  @override
  Tag decode(dynamic value) => Tag(value as String);

  @override
  String encode(Tag self) => self.raw;

  static const single = [TagMapper()];
}


@MappableClass()
class SearchTagsDto({
  @MappableField(key: 'tags')
  required final List<TagDto> value,
}) extends DelegatingList<TagDto> with SearchTagsDtoMappable {
  this : super(value);
  static final fromMap = SearchTagsDtoMapper.fromMap;
  static final fromJson = SearchTagsDtoMapper.fromJson;
}


@MappableClass()
class TagDto({
  @MappableField(key: 'value')
  required String raw,
  required final int count,
}) extends Tag with TagDtoMappable {
  this : super(raw);
}


@MappableClass()
class const FileMetadataResponseDto({
  @MappableField(key: 'metadata')
  required final List<FileMetadataDto> value,
}) extends DelegatingList<FileMetadataDto>
    with FileMetadataResponseDtoMappable {
  this : super(value);
  static final fromMap = FileMetadataResponseDtoMapper.fromMap;
  static final fromJson = FileMetadataResponseDtoMapper.fromJson;
}


/// Put this [Map]'s keys inside it's values which are also of
/// type [Map].
class const IncludeKeysSetNameAsKeyHook() extends MappingHook {
  @override
  Object? beforeDecode(dynamic value) =>
      value.map((k, v) => MapEntry(v['name'], v..['key'] = k));
}


@MappableClass()
class const FileMetadataDto({
  @MappableField(key: 'file_id')
  required final int id,
  required final String hash,
  required final int size,
  required final String mime,
  required final String ext,
  final double width = 0,
  final double height = 0,
  final Duration duration = .zero,
  @MappableField(key: 'is_inbox')
  required final bool inbox,
  @MappableField(hook: IncludeKeysSetNameAsKeyHook())
  required final Map<String, TagService> tags,
}) with FileMetadataDtoMappable;


/// Pick `0` from [Map] as [Iterable], sort tags by namespace and
/// alphabetically, return [Set] of tags.
class const PickZeroAndSortHook() extends MappingHook {
  @override
  List<dynamic> beforeDecode(dynamic value) => value['0'] ?? const [];

  @override
  Set<Tag> afterDecode(dynamic value) =>
      TagSortBuilder(value as Iterable<Tag>)
          .namespace()
          .alphabetical()
          .sort()
          .toSet();
}


@MappableClass(includeCustomMappers: TagMapper.single)
class const TagService({
  required final String name,
  required final String key,
  required final int type,
  @MappableField(key: 'storage_tags', hook: PickZeroAndSortHook())
  required final Set<Tag> storage,
  @MappableField(key: 'display_tags', hook: PickZeroAndSortHook())
  required final Set<Tag> display,
}) with TagServiceMappable {
  bool get editable => type == 5;
}


extension AllTags on Map<String, TagService> {
  TagService get all => this['all known tags']!;
}


/// Tag -> service key -> relations.
@MappableClass()
class const SiblingsAndParentsDto({
  @MappableField(key: 'tags')
  required final Map<Tag, Map<String, TagRelations>> value,
}) extends DelegatingMap<Tag, Map<String, TagRelations>>
    with SiblingsAndParentsDtoMappable {
  this : super(value);
  static final fromMap = SiblingsAndParentsDtoMapper.fromMap;
  static final fromJson = SiblingsAndParentsDtoMapper.fromJson;
}


@MappableClass(includeCustomMappers: TagMapper.single)
class const TagRelations({
  @MappableField(key: 'ideal_tag')
  required final Tag ideal,
  required final List<Tag> ancestors,
}) with TagRelationsMappable;
