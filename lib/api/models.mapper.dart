// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'models.dart';

class FileMetadataEntryDtoMapper extends ClassMapperBase<FileMetadataEntryDto> {
  FileMetadataEntryDtoMapper._();

  static FileMetadataEntryDtoMapper? _instance;
  static FileMetadataEntryDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FileMetadataEntryDtoMapper._());
      TagServiceDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'FileMetadataEntryDto';

  static int _$id(FileMetadataEntryDto v) => v.id;
  static const Field<FileMetadataEntryDto, int> _f$id = Field(
    'id',
    _$id,
    key: r'file_id',
  );
  static String _$hash(FileMetadataEntryDto v) => v.hash;
  static const Field<FileMetadataEntryDto, String> _f$hash = Field(
    'hash',
    _$hash,
  );
  static int _$size(FileMetadataEntryDto v) => v.size;
  static const Field<FileMetadataEntryDto, int> _f$size = Field('size', _$size);
  static String _$mime(FileMetadataEntryDto v) => v.mime;
  static const Field<FileMetadataEntryDto, String> _f$mime = Field(
    'mime',
    _$mime,
  );
  static String _$ext(FileMetadataEntryDto v) => v.ext;
  static const Field<FileMetadataEntryDto, String> _f$ext = Field('ext', _$ext);
  static double _$width(FileMetadataEntryDto v) => v.width;
  static const Field<FileMetadataEntryDto, double> _f$width = Field(
    'width',
    _$width,
    opt: true,
    def: 0,
  );
  static double _$height(FileMetadataEntryDto v) => v.height;
  static const Field<FileMetadataEntryDto, double> _f$height = Field(
    'height',
    _$height,
    opt: true,
    def: 0,
  );
  static Duration _$duration(FileMetadataEntryDto v) => v.duration;
  static const Field<FileMetadataEntryDto, Duration> _f$duration = Field(
    'duration',
    _$duration,
    opt: true,
    def: .zero,
  );
  static bool _$inbox(FileMetadataEntryDto v) => v.inbox;
  static const Field<FileMetadataEntryDto, bool> _f$inbox = Field(
    'inbox',
    _$inbox,
    key: r'is_inbox',
  );
  static Map<String, TagServiceDto> _$tags(FileMetadataEntryDto v) => v.tags;
  static const Field<FileMetadataEntryDto, Map<String, TagServiceDto>> _f$tags =
      Field('tags', _$tags);

  @override
  final MappableFields<FileMetadataEntryDto> fields = const {
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

  static FileMetadataEntryDto _instantiate(DecodingData data) {
    return FileMetadataEntryDto(
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

  static FileMetadataEntryDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<FileMetadataEntryDto>(map);
  }

  static FileMetadataEntryDto fromJson(String json) {
    return ensureInitialized().decodeJson<FileMetadataEntryDto>(json);
  }
}

mixin FileMetadataEntryDtoMappable {
  String toJson() {
    return FileMetadataEntryDtoMapper.ensureInitialized()
        .encodeJson<FileMetadataEntryDto>(this as FileMetadataEntryDto);
  }

  Map<String, dynamic> toMap() {
    return FileMetadataEntryDtoMapper.ensureInitialized()
        .encodeMap<FileMetadataEntryDto>(this as FileMetadataEntryDto);
  }

  FileMetadataEntryDtoCopyWith<
    FileMetadataEntryDto,
    FileMetadataEntryDto,
    FileMetadataEntryDto
  >
  get copyWith =>
      _FileMetadataEntryDtoCopyWithImpl<
        FileMetadataEntryDto,
        FileMetadataEntryDto
      >(this as FileMetadataEntryDto, $identity, $identity);
  @override
  String toString() {
    return FileMetadataEntryDtoMapper.ensureInitialized().stringifyValue(
      this as FileMetadataEntryDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return FileMetadataEntryDtoMapper.ensureInitialized().equalsValue(
      this as FileMetadataEntryDto,
      other,
    );
  }

  @override
  int get hashCode {
    return FileMetadataEntryDtoMapper.ensureInitialized().hashValue(
      this as FileMetadataEntryDto,
    );
  }
}

extension FileMetadataEntryDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, FileMetadataEntryDto, $Out> {
  FileMetadataEntryDtoCopyWith<$R, FileMetadataEntryDto, $Out>
  get $asFileMetadataEntryDto => $base.as(
    (v, t, t2) => _FileMetadataEntryDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class FileMetadataEntryDtoCopyWith<
  $R,
  $In extends FileMetadataEntryDto,
  $Out
>
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
  FileMetadataEntryDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _FileMetadataEntryDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, FileMetadataEntryDto, $Out>
    implements FileMetadataEntryDtoCopyWith<$R, FileMetadataEntryDto, $Out> {
  _FileMetadataEntryDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<FileMetadataEntryDto> $mapper =
      FileMetadataEntryDtoMapper.ensureInitialized();
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
  FileMetadataEntryDto $make(CopyWithData data) => FileMetadataEntryDto(
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
  FileMetadataEntryDtoCopyWith<$R2, FileMetadataEntryDto, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _FileMetadataEntryDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TagServiceDtoMapper extends ClassMapperBase<TagServiceDto> {
  TagServiceDtoMapper._();

  static TagServiceDtoMapper? _instance;
  static TagServiceDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TagServiceDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'TagServiceDto';

  static String _$name(TagServiceDto v) => v.name;
  static const Field<TagServiceDto, String> _f$name = Field('name', _$name);
  static int _$type(TagServiceDto v) => v.type;
  static const Field<TagServiceDto, int> _f$type = Field('type', _$type);
  static Map<String, List<String>> _$storageTags(TagServiceDto v) =>
      v.storageTags;
  static const Field<TagServiceDto, Map<String, List<String>>> _f$storageTags =
      Field('storageTags', _$storageTags, key: r'storage_tags');
  static Map<String, List<String>> _$displayTags(TagServiceDto v) =>
      v.displayTags;
  static const Field<TagServiceDto, Map<String, List<String>>> _f$displayTags =
      Field('displayTags', _$displayTags, key: r'display_tags');

  @override
  final MappableFields<TagServiceDto> fields = const {
    #name: _f$name,
    #type: _f$type,
    #storageTags: _f$storageTags,
    #displayTags: _f$displayTags,
  };

  static TagServiceDto _instantiate(DecodingData data) {
    return TagServiceDto(
      name: data.dec(_f$name),
      type: data.dec(_f$type),
      storageTags: data.dec(_f$storageTags),
      displayTags: data.dec(_f$displayTags),
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
  MapCopyWith<
    $R,
    String,
    List<String>,
    ObjectCopyWith<$R, List<String>, List<String>>
  >
  get storageTags;
  MapCopyWith<
    $R,
    String,
    List<String>,
    ObjectCopyWith<$R, List<String>, List<String>>
  >
  get displayTags;
  $R call({
    String? name,
    int? type,
    Map<String, List<String>>? storageTags,
    Map<String, List<String>>? displayTags,
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
  MapCopyWith<
    $R,
    String,
    List<String>,
    ObjectCopyWith<$R, List<String>, List<String>>
  >
  get storageTags => MapCopyWith(
    $value.storageTags,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(storageTags: v),
  );
  @override
  MapCopyWith<
    $R,
    String,
    List<String>,
    ObjectCopyWith<$R, List<String>, List<String>>
  >
  get displayTags => MapCopyWith(
    $value.displayTags,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(displayTags: v),
  );
  @override
  $R call({
    String? name,
    int? type,
    Map<String, List<String>>? storageTags,
    Map<String, List<String>>? displayTags,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (type != null) #type: type,
      if (storageTags != null) #storageTags: storageTags,
      if (displayTags != null) #displayTags: displayTags,
    }),
  );
  @override
  TagServiceDto $make(CopyWithData data) => TagServiceDto(
    name: data.get(#name, or: $value.name),
    type: data.get(#type, or: $value.type),
    storageTags: data.get(#storageTags, or: $value.storageTags),
    displayTags: data.get(#displayTags, or: $value.displayTags),
  );

  @override
  TagServiceDtoCopyWith<$R2, TagServiceDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TagServiceDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

