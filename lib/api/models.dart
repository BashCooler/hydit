import 'package:dart_mappable/dart_mappable.dart';

part 'models.mapper.dart';


@MappableClass(caseStyle: .snakeCase)
class FileMetadataEntryDto({
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
  required final Map<String, TagServiceDto> tags,
}) with FileMetadataEntryDtoMappable {
  static final fromMap = FileMetadataEntryDtoMapper.fromMap;
  static final fromJson = FileMetadataEntryDtoMapper.fromJson;
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