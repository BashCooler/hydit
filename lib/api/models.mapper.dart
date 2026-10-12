// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'models.dart';

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

  static Map<Tag, Map<String, TagRelations>> _$tags(SiblingsAndParentsDto v) =>
      v.tags;
  static const Field<SiblingsAndParentsDto, Map<Tag, Map<String, TagRelations>>>
  _f$tags = Field('tags', _$tags);

  @override
  final MappableFields<SiblingsAndParentsDto> fields = const {#tags: _f$tags};

  static SiblingsAndParentsDto _instantiate(DecodingData data) {
    return SiblingsAndParentsDto(tags: data.dec(_f$tags));
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

mixin SiblingsAndParentsDtoMappable {
  String toJson() {
    return SiblingsAndParentsDtoMapper.ensureInitialized()
        .encodeJson<SiblingsAndParentsDto>(this as SiblingsAndParentsDto);
  }

  Map<String, dynamic> toMap() {
    return SiblingsAndParentsDtoMapper.ensureInitialized()
        .encodeMap<SiblingsAndParentsDto>(this as SiblingsAndParentsDto);
  }

  SiblingsAndParentsDtoCopyWith<
    SiblingsAndParentsDto,
    SiblingsAndParentsDto,
    SiblingsAndParentsDto
  >
  get copyWith =>
      _SiblingsAndParentsDtoCopyWithImpl<
        SiblingsAndParentsDto,
        SiblingsAndParentsDto
      >(this as SiblingsAndParentsDto, $identity, $identity);
  @override
  String toString() {
    return SiblingsAndParentsDtoMapper.ensureInitialized().stringifyValue(
      this as SiblingsAndParentsDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return SiblingsAndParentsDtoMapper.ensureInitialized().equalsValue(
      this as SiblingsAndParentsDto,
      other,
    );
  }

  @override
  int get hashCode {
    return SiblingsAndParentsDtoMapper.ensureInitialized().hashValue(
      this as SiblingsAndParentsDto,
    );
  }
}

extension SiblingsAndParentsDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SiblingsAndParentsDto, $Out> {
  SiblingsAndParentsDtoCopyWith<$R, SiblingsAndParentsDto, $Out>
  get $asSiblingsAndParentsDto => $base.as(
    (v, t, t2) => _SiblingsAndParentsDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class SiblingsAndParentsDtoCopyWith<
  $R,
  $In extends SiblingsAndParentsDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<
    $R,
    Tag,
    Map<String, TagRelations>,
    ObjectCopyWith<$R, Map<String, TagRelations>, Map<String, TagRelations>>
  >
  get tags;
  $R call({Map<Tag, Map<String, TagRelations>>? tags});
  SiblingsAndParentsDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _SiblingsAndParentsDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SiblingsAndParentsDto, $Out>
    implements SiblingsAndParentsDtoCopyWith<$R, SiblingsAndParentsDto, $Out> {
  _SiblingsAndParentsDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SiblingsAndParentsDto> $mapper =
      SiblingsAndParentsDtoMapper.ensureInitialized();
  @override
  MapCopyWith<
    $R,
    Tag,
    Map<String, TagRelations>,
    ObjectCopyWith<$R, Map<String, TagRelations>, Map<String, TagRelations>>
  >
  get tags => MapCopyWith(
    $value.tags,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(tags: v),
  );
  @override
  $R call({Map<Tag, Map<String, TagRelations>>? tags}) =>
      $apply(FieldCopyWithData({if (tags != null) #tags: tags}));
  @override
  SiblingsAndParentsDto $make(CopyWithData data) =>
      SiblingsAndParentsDto(tags: data.get(#tags, or: $value.tags));

  @override
  SiblingsAndParentsDtoCopyWith<$R2, SiblingsAndParentsDto, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _SiblingsAndParentsDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

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

mixin TagRelationsMappable {
  String toJson() {
    return TagRelationsMapper.ensureInitialized().encodeJson<TagRelations>(
      this as TagRelations,
    );
  }

  Map<String, dynamic> toMap() {
    return TagRelationsMapper.ensureInitialized().encodeMap<TagRelations>(
      this as TagRelations,
    );
  }

  TagRelationsCopyWith<TagRelations, TagRelations, TagRelations> get copyWith =>
      _TagRelationsCopyWithImpl<TagRelations, TagRelations>(
        this as TagRelations,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TagRelationsMapper.ensureInitialized().stringifyValue(
      this as TagRelations,
    );
  }

  @override
  bool operator ==(Object other) {
    return TagRelationsMapper.ensureInitialized().equalsValue(
      this as TagRelations,
      other,
    );
  }

  @override
  int get hashCode {
    return TagRelationsMapper.ensureInitialized().hashValue(
      this as TagRelations,
    );
  }
}

extension TagRelationsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TagRelations, $Out> {
  TagRelationsCopyWith<$R, TagRelations, $Out> get $asTagRelations =>
      $base.as((v, t, t2) => _TagRelationsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TagRelationsCopyWith<$R, $In extends TagRelations, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Tag, ObjectCopyWith<$R, Tag, Tag>> get ancestors;
  $R call({Tag? ideal, List<Tag>? ancestors});
  TagRelationsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TagRelationsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TagRelations, $Out>
    implements TagRelationsCopyWith<$R, TagRelations, $Out> {
  _TagRelationsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TagRelations> $mapper =
      TagRelationsMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Tag, ObjectCopyWith<$R, Tag, Tag>> get ancestors =>
      ListCopyWith(
        $value.ancestors,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(ancestors: v),
      );
  @override
  $R call({Tag? ideal, List<Tag>? ancestors}) => $apply(
    FieldCopyWithData({
      if (ideal != null) #ideal: ideal,
      if (ancestors != null) #ancestors: ancestors,
    }),
  );
  @override
  TagRelations $make(CopyWithData data) => TagRelations(
    ideal: data.get(#ideal, or: $value.ideal),
    ancestors: data.get(#ancestors, or: $value.ancestors),
  );

  @override
  TagRelationsCopyWith<$R2, TagRelations, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TagRelationsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

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

  static List<FileMetadataDto> _$metadata(FileMetadataResponseDto v) =>
      v.metadata;
  static const Field<FileMetadataResponseDto, List<FileMetadataDto>>
  _f$metadata = Field('metadata', _$metadata);

  @override
  final MappableFields<FileMetadataResponseDto> fields = const {
    #metadata: _f$metadata,
  };

  static FileMetadataResponseDto _instantiate(DecodingData data) {
    return FileMetadataResponseDto(metadata: data.dec(_f$metadata));
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

mixin FileMetadataResponseDtoMappable {
  String toJson() {
    return FileMetadataResponseDtoMapper.ensureInitialized()
        .encodeJson<FileMetadataResponseDto>(this as FileMetadataResponseDto);
  }

  Map<String, dynamic> toMap() {
    return FileMetadataResponseDtoMapper.ensureInitialized()
        .encodeMap<FileMetadataResponseDto>(this as FileMetadataResponseDto);
  }

  FileMetadataResponseDtoCopyWith<
    FileMetadataResponseDto,
    FileMetadataResponseDto,
    FileMetadataResponseDto
  >
  get copyWith =>
      _FileMetadataResponseDtoCopyWithImpl<
        FileMetadataResponseDto,
        FileMetadataResponseDto
      >(this as FileMetadataResponseDto, $identity, $identity);
  @override
  String toString() {
    return FileMetadataResponseDtoMapper.ensureInitialized().stringifyValue(
      this as FileMetadataResponseDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return FileMetadataResponseDtoMapper.ensureInitialized().equalsValue(
      this as FileMetadataResponseDto,
      other,
    );
  }

  @override
  int get hashCode {
    return FileMetadataResponseDtoMapper.ensureInitialized().hashValue(
      this as FileMetadataResponseDto,
    );
  }
}

extension FileMetadataResponseDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, FileMetadataResponseDto, $Out> {
  FileMetadataResponseDtoCopyWith<$R, FileMetadataResponseDto, $Out>
  get $asFileMetadataResponseDto => $base.as(
    (v, t, t2) => _FileMetadataResponseDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class FileMetadataResponseDtoCopyWith<
  $R,
  $In extends FileMetadataResponseDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    FileMetadataDto,
    FileMetadataDtoCopyWith<$R, FileMetadataDto, FileMetadataDto>
  >
  get metadata;
  $R call({List<FileMetadataDto>? metadata});
  FileMetadataResponseDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _FileMetadataResponseDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, FileMetadataResponseDto, $Out>
    implements
        FileMetadataResponseDtoCopyWith<$R, FileMetadataResponseDto, $Out> {
  _FileMetadataResponseDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<FileMetadataResponseDto> $mapper =
      FileMetadataResponseDtoMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    FileMetadataDto,
    FileMetadataDtoCopyWith<$R, FileMetadataDto, FileMetadataDto>
  >
  get metadata => ListCopyWith(
    $value.metadata,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(metadata: v),
  );
  @override
  $R call({List<FileMetadataDto>? metadata}) =>
      $apply(FieldCopyWithData({if (metadata != null) #metadata: metadata}));
  @override
  FileMetadataResponseDto $make(CopyWithData data) => FileMetadataResponseDto(
    metadata: data.get(#metadata, or: $value.metadata),
  );

  @override
  FileMetadataResponseDtoCopyWith<$R2, FileMetadataResponseDto, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _FileMetadataResponseDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class FileMetadataDtoMapper extends ClassMapperBase<FileMetadataDto> {
  FileMetadataDtoMapper._();

  static FileMetadataDtoMapper? _instance;
  static FileMetadataDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FileMetadataDtoMapper._());
      TagServiceDtoMapper.ensureInitialized();
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
  static Map<String, TagServiceDto> _$tags(FileMetadataDto v) => v.tags;
  static const Field<FileMetadataDto, Map<String, TagServiceDto>> _f$tags =
      Field('tags', _$tags, hook: IncludeKeys());

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

mixin FileMetadataDtoMappable {
  String toJson() {
    return FileMetadataDtoMapper.ensureInitialized()
        .encodeJson<FileMetadataDto>(this as FileMetadataDto);
  }

  Map<String, dynamic> toMap() {
    return FileMetadataDtoMapper.ensureInitialized().encodeMap<FileMetadataDto>(
      this as FileMetadataDto,
    );
  }

  FileMetadataDtoCopyWith<FileMetadataDto, FileMetadataDto, FileMetadataDto>
  get copyWith =>
      _FileMetadataDtoCopyWithImpl<FileMetadataDto, FileMetadataDto>(
        this as FileMetadataDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return FileMetadataDtoMapper.ensureInitialized().stringifyValue(
      this as FileMetadataDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return FileMetadataDtoMapper.ensureInitialized().equalsValue(
      this as FileMetadataDto,
      other,
    );
  }

  @override
  int get hashCode {
    return FileMetadataDtoMapper.ensureInitialized().hashValue(
      this as FileMetadataDto,
    );
  }
}

extension FileMetadataDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, FileMetadataDto, $Out> {
  FileMetadataDtoCopyWith<$R, FileMetadataDto, $Out> get $asFileMetadataDto =>
      $base.as((v, t, t2) => _FileMetadataDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class FileMetadataDtoCopyWith<$R, $In extends FileMetadataDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<
    $R,
    String,
    TagServiceDto,
    TagServiceDtoCopyWith<$R, TagServiceDto, TagServiceDto>
  >
  get tags;
  $R call({
    int? id,
    String? hash,
    int? size,
    String? mime,
    String? ext,
    double? width,
    double? height,
    Duration? duration,
    bool? inbox,
    Map<String, TagServiceDto>? tags,
  });
  FileMetadataDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _FileMetadataDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, FileMetadataDto, $Out>
    implements FileMetadataDtoCopyWith<$R, FileMetadataDto, $Out> {
  _FileMetadataDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<FileMetadataDto> $mapper =
      FileMetadataDtoMapper.ensureInitialized();
  @override
  MapCopyWith<
    $R,
    String,
    TagServiceDto,
    TagServiceDtoCopyWith<$R, TagServiceDto, TagServiceDto>
  >
  get tags => MapCopyWith(
    $value.tags,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(tags: v),
  );
  @override
  $R call({
    int? id,
    String? hash,
    int? size,
    String? mime,
    String? ext,
    double? width,
    double? height,
    Duration? duration,
    bool? inbox,
    Map<String, TagServiceDto>? tags,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (hash != null) #hash: hash,
      if (size != null) #size: size,
      if (mime != null) #mime: mime,
      if (ext != null) #ext: ext,
      if (width != null) #width: width,
      if (height != null) #height: height,
      if (duration != null) #duration: duration,
      if (inbox != null) #inbox: inbox,
      if (tags != null) #tags: tags,
    }),
  );
  @override
  FileMetadataDto $make(CopyWithData data) => FileMetadataDto(
    id: data.get(#id, or: $value.id),
    hash: data.get(#hash, or: $value.hash),
    size: data.get(#size, or: $value.size),
    mime: data.get(#mime, or: $value.mime),
    ext: data.get(#ext, or: $value.ext),
    width: data.get(#width, or: $value.width),
    height: data.get(#height, or: $value.height),
    duration: data.get(#duration, or: $value.duration),
    inbox: data.get(#inbox, or: $value.inbox),
    tags: data.get(#tags, or: $value.tags),
  );

  @override
  FileMetadataDtoCopyWith<$R2, FileMetadataDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _FileMetadataDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TagServiceDtoMapper extends ClassMapperBase<TagServiceDto> {
  TagServiceDtoMapper._();

  static TagServiceDtoMapper? _instance;
  static TagServiceDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TagServiceDtoMapper._());
      MapperContainer.globals.useAll(TagMapper.single);
    }
    return _instance!;
  }

  @override
  final String id = 'TagServiceDto';

  static String _$name(TagServiceDto v) => v.name;
  static const Field<TagServiceDto, String> _f$name = Field('name', _$name);
  static String _$key(TagServiceDto v) => v.key;
  static const Field<TagServiceDto, String> _f$key = Field('key', _$key);
  static int _$type(TagServiceDto v) => v.type;
  static const Field<TagServiceDto, int> _f$type = Field('type', _$type);
  static Set<Tag> _$storage(TagServiceDto v) => v.storage;
  static const Field<TagServiceDto, Set<Tag>> _f$storage = Field(
    'storage',
    _$storage,
    key: r'storage_tags',
    hook: PickZeroAndSortHook(),
  );
  static Set<Tag> _$display(TagServiceDto v) => v.display;
  static const Field<TagServiceDto, Set<Tag>> _f$display = Field(
    'display',
    _$display,
    key: r'display_tags',
    hook: PickZeroAndSortHook(),
  );

  @override
  final MappableFields<TagServiceDto> fields = const {
    #name: _f$name,
    #key: _f$key,
    #type: _f$type,
    #storage: _f$storage,
    #display: _f$display,
  };

  static TagServiceDto _instantiate(DecodingData data) {
    return TagServiceDto(
      name: data.dec(_f$name),
      key: data.dec(_f$key),
      type: data.dec(_f$type),
      storage: data.dec(_f$storage),
      display: data.dec(_f$display),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TagServiceDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TagServiceDto>(map);
  }

  static TagServiceDto fromJson(String json) {
    return ensureInitialized().decodeJson<TagServiceDto>(json);
  }
}

mixin TagServiceDtoMappable {
  String toJson() {
    return TagServiceDtoMapper.ensureInitialized().encodeJson<TagServiceDto>(
      this as TagServiceDto,
    );
  }

  Map<String, dynamic> toMap() {
    return TagServiceDtoMapper.ensureInitialized().encodeMap<TagServiceDto>(
      this as TagServiceDto,
    );
  }

  TagServiceDtoCopyWith<TagServiceDto, TagServiceDto, TagServiceDto>
  get copyWith => _TagServiceDtoCopyWithImpl<TagServiceDto, TagServiceDto>(
    this as TagServiceDto,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return TagServiceDtoMapper.ensureInitialized().stringifyValue(
      this as TagServiceDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return TagServiceDtoMapper.ensureInitialized().equalsValue(
      this as TagServiceDto,
      other,
    );
  }

  @override
  int get hashCode {
    return TagServiceDtoMapper.ensureInitialized().hashValue(
      this as TagServiceDto,
    );
  }
}

extension TagServiceDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TagServiceDto, $Out> {
  TagServiceDtoCopyWith<$R, TagServiceDto, $Out> get $asTagServiceDto =>
      $base.as((v, t, t2) => _TagServiceDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TagServiceDtoCopyWith<$R, $In extends TagServiceDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? name,
    String? key,
    int? type,
    Set<Tag>? storage,
    Set<Tag>? display,
  });
  TagServiceDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TagServiceDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TagServiceDto, $Out>
    implements TagServiceDtoCopyWith<$R, TagServiceDto, $Out> {
  _TagServiceDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TagServiceDto> $mapper =
      TagServiceDtoMapper.ensureInitialized();
  @override
  $R call({
    String? name,
    String? key,
    int? type,
    Set<Tag>? storage,
    Set<Tag>? display,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (key != null) #key: key,
      if (type != null) #type: type,
      if (storage != null) #storage: storage,
      if (display != null) #display: display,
    }),
  );
  @override
  TagServiceDto $make(CopyWithData data) => TagServiceDto(
    name: data.get(#name, or: $value.name),
    key: data.get(#key, or: $value.key),
    type: data.get(#type, or: $value.type),
    storage: data.get(#storage, or: $value.storage),
    display: data.get(#display, or: $value.display),
  );

  @override
  TagServiceDtoCopyWith<$R2, TagServiceDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TagServiceDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

