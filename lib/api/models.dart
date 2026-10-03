import 'package:dart_mappable/dart_mappable.dart';

part 'models.mapper.dart';


@MappableClass(caseStyle: .snakeCase)
class MetadataEntryDto({
  @MappableField(key: 'file_id')
  required final int id,
  required final String hash,
  final double width = 0,
  final double height = 0,
  required final int size,
  required final String mime,
  final Duration duration = .zero,
  required final String ext,
  required final Map<String, TagServiceDto> tags,
}) with MetadataEntryDtoMappable {
  static final fromMap = MetadataEntryDtoMapper.fromMap;
  static final fromJson = MetadataEntryDtoMapper.fromJson;
}


@MappableClass(caseStyle: .snakeCase)
class TagServiceDto({
  required final String name,
  required final int type,
  required final Map<String, List<String>> storageTags,
  required final Map<String, List<String>> displayTags,
}) with TagServiceDtoMappable {
  static final fromMap = TagServiceDtoMapper.fromMap;
  static final fromJson = TagServiceDtoMapper.fromJson;
}