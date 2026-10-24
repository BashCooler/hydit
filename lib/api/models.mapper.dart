// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'models.dart';

class SearchTagsDtoMapper extends ClassMapperBase<SearchTagsDto> {
  SearchTagsDtoMapper._();

  static SearchTagsDtoMapper? _instance;
  static SearchTagsDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SearchTagsDtoMapper._());
      TagDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'SearchTagsDto';

  static List<TagDto> _$value(SearchTagsDto v) => v.value;
  static const Field<SearchTagsDto, List<TagDto>> _f$value = Field(
    'value',
    _$value,
    key: r'tags',
  );

  @override
  final MappableFields<SearchTagsDto> fields = const {#value: _f$value};

  static SearchTagsDto _instantiate(DecodingData data) {
    return SearchTagsDto(value: data.dec(_f$value));
  }

  @override
  final Function instantiate = _instantiate;

  static SearchTagsDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SearchTagsDto>(map);
  }

  static SearchTagsDto fromJson(String json) {
    return ensureInitialized().decodeJson<SearchTagsDto>(json);
  }
}

mixin SearchTagsDtoMappable {}

class TagDtoMapper extends ClassMapperBase<TagDto> {
  TagDtoMapper._();

  static TagDtoMapper? _instance;
  static TagDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TagDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'TagDto';

  static String _$raw(TagDto v) => v.raw;
  static const Field<TagDto, String> _f$raw = Field(
    'raw',
    _$raw,
    key: r'value',
  );
  static int _$count(TagDto v) => v.count;
  static const Field<TagDto, int> _f$count = Field('count', _$count);

  @override
  final MappableFields<TagDto> fields = const {#raw: _f$raw, #count: _f$count};

  static TagDto _instantiate(DecodingData data) {
    return TagDto(raw: data.dec(_f$raw), count: data.dec(_f$count));
  }

  @override
  final Function instantiate = _instantiate;

  static TagDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TagDto>(map);
  }

  static TagDto fromJson(String json) {
    return ensureInitialized().decodeJson<TagDto>(json);
  }
}

mixin TagDtoMappable {}

class FileMetadataResponseDtoMapper
    extends ClassMapperBase<FileMetadataResponseDto> {
  FileMetadataResponseDtoMapper._();

  static FileMetadataResponseDtoMapper? _instance;
  static FileMetadataResponseDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = FileMetadataResponseDtoMapper._(),
      );
      FileMetadataDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'FileMetadataResponseDto';

  static List<FileMetadataDto> _$value(FileMetadataResponseDto v) => v.value;
  static const Field<FileMetadataResponseDto, List<FileMetadataDto>> _f$value =
      Field('value', _$value, key: r'metadata');

  @override
  final MappableFields<FileMetadataResponseDto> fields = const {
    #value: _f$value,
  };

  static FileMetadataResponseDto _instantiate(DecodingData data) {
    return FileMetadataResponseDto(value: data.dec(_f$value));
  }

  @override
  final Function instantiate = _instantiate;

  static FileMetadataResponseDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<FileMetadataResponseDto>(map);
  }

  static FileMetadataResponseDto fromJson(String json) {
    return ensureInitialized().decodeJson<FileMetadataResponseDto>(json);
  }
}

mixin FileMetadataResponseDtoMappable {}

class FileMetadataDtoMapper extends ClassMapperBase<FileMetadataDto> {
  FileMetadataDtoMapper._();

  static FileMetadataDtoMapper? _instance;
  static FileMetadataDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FileMetadataDtoMapper._());
      TagServiceMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'FileMetadataDto';

  static int _$id(FileMetadataDto v) => v.id;
  static const Field<FileMetadataDto, int> _f$id = Field(
    'id',
    _$id,
    key: r'file_id',
  );
  static String _$hash(FileMetadataDto v) => v.hash;
  static const Field<FileMetadataDto, String> _f$hash = Field('hash', _$hash);
  static int _$size(FileMetadataDto v) => v.size;
  static const Field<FileMetadataDto, int> _f$size = Field('size', _$size);
  static String _$mime(FileMetadataDto v) => v.mime;
  static const Field<FileMetadataDto, String> _f$mime = Field('mime', _$mime);
  static String _$ext(FileMetadataDto v) => v.ext;
  static const Field<FileMetadataDto, String> _f$ext = Field('ext', _$ext);
  static double _$width(FileMetadataDto v) => v.width;
  static const Field<FileMetadataDto, double> _f$width = Field(
    'width',
    _$width,
    opt: true,
    def: 0,
  );
  static double _$height(FileMetadataDto v) => v.height;
  static const Field<FileMetadataDto, double> _f$height = Field(
    'height',
    _$height,
    opt: true,
    def: 0,
  );
  static Duration _$duration(FileMetadataDto v) => v.duration;
  static const Field<FileMetadataDto, Duration> _f$duration = Field(
    'duration',
    _$duration,
    opt: true,
    def: .zero,
  );
  static bool _$inbox(FileMetadataDto v) => v.inbox;
  static const Field<FileMetadataDto, bool> _f$inbox = Field(
    'inbox',
    _$inbox,
    key: r'is_inbox',
  );
  static Map<String, TagService> _$tags(FileMetadataDto v) => v.tags;
  static const Field<FileMetadataDto, Map<String, TagService>> _f$tags = Field(
    'tags',
    _$tags,
    hook: IncludeKeysSetNameAsKeyHook(),
  );

  @override
  final MappableFields<FileMetadataDto> fields = const {
    #id: _f$id,
    #hash: _f$hash,
    #size: _f$size,
    #mime: _f$mime,
    #ext: _f$ext,
    #width: _f$width,
    #height: _f$height,
    #duration: _f$duration,
    #inbox: _f$inbox,
    #tags: _f$tags,
  };

  static FileMetadataDto _instantiate(DecodingData data) {
    return FileMetadataDto(
      id: data.dec(_f$id),
      hash: data.dec(_f$hash),
      size: data.dec(_f$size),
      mime: data.dec(_f$mime),
      ext: data.dec(_f$ext),
      width: data.dec(_f$width),
      height: data.dec(_f$height),
      duration: data.dec(_f$duration),
      inbox: data.dec(_f$inbox),
      tags: data.dec(_f$tags),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static FileMetadataDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<FileMetadataDto>(map);
  }

  static FileMetadataDto fromJson(String json) {
    return ensureInitialized().decodeJson<FileMetadataDto>(json);
  }
}

mixin FileMetadataDtoMappable {}

class TagServiceMapper extends ClassMapperBase<TagService> {
  TagServiceMapper._();

  static TagServiceMapper? _instance;
  static TagServiceMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TagServiceMapper._());
      MapperContainer.globals.useAll(TagMapper.single);
    }
    return _instance!;
  }

  @override
  final String id = 'TagService';

  static String _$name(TagService v) => v.name;
  static const Field<TagService, String> _f$name = Field('name', _$name);
  static String _$key(TagService v) => v.key;
  static const Field<TagService, String> _f$key = Field('key', _$key);
  static int _$type(TagService v) => v.type;
  static const Field<TagService, int> _f$type = Field('type', _$type);
  static Set<Tag> _$storage(TagService v) => v.storage;
  static const Field<TagService, Set<Tag>> _f$storage = Field(
    'storage',
    _$storage,
    key: r'storage_tags',
    hook: PickZeroAndSortHook(),
  );
  static Set<Tag> _$display(TagService v) => v.display;
  static const Field<TagService, Set<Tag>> _f$display = Field(
    'display',
    _$display,
    key: r'display_tags',
    hook: PickZeroAndSortHook(),
  );

  @override
  final MappableFields<TagService> fields = const {
    #name: _f$name,
    #key: _f$key,
    #type: _f$type,
    #storage: _f$storage,
    #display: _f$display,
  };

  static TagService _instantiate(DecodingData data) {
    return TagService(
      name: data.dec(_f$name),
      key: data.dec(_f$key),
      type: data.dec(_f$type),
      storage: data.dec(_f$storage),
      display: data.dec(_f$display),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TagService fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TagService>(map);
  }

  static TagService fromJson(String json) {
    return ensureInitialized().decodeJson<TagService>(json);
  }
}

mixin TagServiceMappable {}

class SiblingsAndParentsDtoMapper
    extends ClassMapperBase<SiblingsAndParentsDto> {
  SiblingsAndParentsDtoMapper._();

  static SiblingsAndParentsDtoMapper? _instance;
  static SiblingsAndParentsDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SiblingsAndParentsDtoMapper._());
      TagRelationsMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'SiblingsAndParentsDto';

  static Map<Tag, Map<String, TagRelations>> _$value(SiblingsAndParentsDto v) =>
      v.value;
  static const Field<SiblingsAndParentsDto, Map<Tag, Map<String, TagRelations>>>
  _f$value = Field('value', _$value, key: r'tags');

  @override
  final MappableFields<SiblingsAndParentsDto> fields = const {#value: _f$value};

  static SiblingsAndParentsDto _instantiate(DecodingData data) {
    return SiblingsAndParentsDto(value: data.dec(_f$value));
  }

  @override
  final Function instantiate = _instantiate;

  static SiblingsAndParentsDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SiblingsAndParentsDto>(map);
  }

  static SiblingsAndParentsDto fromJson(String json) {
    return ensureInitialized().decodeJson<SiblingsAndParentsDto>(json);
  }
}

mixin SiblingsAndParentsDtoMappable {}

class TagRelationsMapper extends ClassMapperBase<TagRelations> {
  TagRelationsMapper._();

  static TagRelationsMapper? _instance;
  static TagRelationsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TagRelationsMapper._());
      MapperContainer.globals.useAll(TagMapper.single);
    }
    return _instance!;
  }

  @override
  final String id = 'TagRelations';

  static Tag _$ideal(TagRelations v) => v.ideal;
  static const Field<TagRelations, Tag> _f$ideal = Field(
    'ideal',
    _$ideal,
    key: r'ideal_tag',
  );
  static List<Tag> _$ancestors(TagRelations v) => v.ancestors;
  static const Field<TagRelations, List<Tag>> _f$ancestors = Field(
    'ancestors',
    _$ancestors,
  );

  @override
  final MappableFields<TagRelations> fields = const {
    #ideal: _f$ideal,
    #ancestors: _f$ancestors,
  };

  static TagRelations _instantiate(DecodingData data) {
    return TagRelations(
      ideal: data.dec(_f$ideal),
      ancestors: data.dec(_f$ancestors),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TagRelations fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TagRelations>(map);
  }

  static TagRelations fromJson(String json) {
    return ensureInitialized().decodeJson<TagRelations>(json);
  }
}

mixin TagRelationsMappable {}

