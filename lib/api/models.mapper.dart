// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'models.dart';

class MetadataEntryDtoMapper extends ClassMapperBase<MetadataEntryDto> {
  MetadataEntryDtoMapper._();

  static MetadataEntryDtoMapper? _instance;
  static MetadataEntryDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MetadataEntryDtoMapper._());
      TagServiceDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MetadataEntryDto';

  static int _$id(MetadataEntryDto v) => v.id;
  static const Field<MetadataEntryDto, int> _f$id = Field(
    'id',
    _$id,
    key: r'file_id',
  );
  static String _$hash(MetadataEntryDto v) => v.hash;
  static const Field<MetadataEntryDto, String> _f$hash = Field('hash', _$hash);
  static double _$width(MetadataEntryDto v) => v.width;
  static const Field<MetadataEntryDto, double> _f$width = Field(
    'width',
    _$width,
    opt: true,
    def: 0,
  );
  static double _$height(MetadataEntryDto v) => v.height;
  static const Field<MetadataEntryDto, double> _f$height = Field(
    'height',
    _$height,
    opt: true,
    def: 0,
  );
  static int _$size(MetadataEntryDto v) => v.size;
  static const Field<MetadataEntryDto, int> _f$size = Field('size', _$size);
  static String _$mime(MetadataEntryDto v) => v.mime;
  static const Field<MetadataEntryDto, String> _f$mime = Field('mime', _$mime);
  static Duration _$duration(MetadataEntryDto v) => v.duration;
  static const Field<MetadataEntryDto, Duration> _f$duration = Field(
    'duration',
    _$duration,
    opt: true,
    def: .zero,
  );
  static String _$ext(MetadataEntryDto v) => v.ext;
  static const Field<MetadataEntryDto, String> _f$ext = Field('ext', _$ext);
  static Map<String, TagServiceDto> _$tags(MetadataEntryDto v) => v.tags;
  static const Field<MetadataEntryDto, Map<String, TagServiceDto>> _f$tags =
      Field('tags', _$tags);

  @override
  final MappableFields<MetadataEntryDto> fields = const {
    #id: _f$id,
    #hash: _f$hash,
    #width: _f$width,
    #height: _f$height,
    #size: _f$size,
    #mime: _f$mime,
    #duration: _f$duration,
    #ext: _f$ext,
    #tags: _f$tags,
  };

  static MetadataEntryDto _instantiate(DecodingData data) {
    return MetadataEntryDto(
      id: data.dec(_f$id),
      hash: data.dec(_f$hash),
      width: data.dec(_f$width),
      height: data.dec(_f$height),
      size: data.dec(_f$size),
      mime: data.dec(_f$mime),
      duration: data.dec(_f$duration),
      ext: data.dec(_f$ext),
      tags: data.dec(_f$tags),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MetadataEntryDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MetadataEntryDto>(map);
  }

  static MetadataEntryDto fromJson(String json) {
    return ensureInitialized().decodeJson<MetadataEntryDto>(json);
  }
}

mixin MetadataEntryDtoMappable {
  String toJson() {
    return MetadataEntryDtoMapper.ensureInitialized()
        .encodeJson<MetadataEntryDto>(this as MetadataEntryDto);
  }

  Map<String, dynamic> toMap() {
    return MetadataEntryDtoMapper.ensureInitialized()
        .encodeMap<MetadataEntryDto>(this as MetadataEntryDto);
  }

  MetadataEntryDtoCopyWith<MetadataEntryDto, MetadataEntryDto, MetadataEntryDto>
  get copyWith =>
      _MetadataEntryDtoCopyWithImpl<MetadataEntryDto, MetadataEntryDto>(
        this as MetadataEntryDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MetadataEntryDtoMapper.ensureInitialized().stringifyValue(
      this as MetadataEntryDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return MetadataEntryDtoMapper.ensureInitialized().equalsValue(
      this as MetadataEntryDto,
      other,
    );
  }

  @override
  int get hashCode {
    return MetadataEntryDtoMapper.ensureInitialized().hashValue(
      this as MetadataEntryDto,
    );
  }
}

extension MetadataEntryDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MetadataEntryDto, $Out> {
  MetadataEntryDtoCopyWith<$R, MetadataEntryDto, $Out>
  get $asMetadataEntryDto =>
      $base.as((v, t, t2) => _MetadataEntryDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MetadataEntryDtoCopyWith<$R, $In extends MetadataEntryDto, $Out>
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
    double? width,
    double? height,
    int? size,
    String? mime,
    Duration? duration,
    String? ext,
    Map<String, TagServiceDto>? tags,
  });
  MetadataEntryDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MetadataEntryDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MetadataEntryDto, $Out>
    implements MetadataEntryDtoCopyWith<$R, MetadataEntryDto, $Out> {
  _MetadataEntryDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MetadataEntryDto> $mapper =
      MetadataEntryDtoMapper.ensureInitialized();
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
    double? width,
    double? height,
    int? size,
    String? mime,
    Duration? duration,
    String? ext,
    Map<String, TagServiceDto>? tags,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (hash != null) #hash: hash,
      if (width != null) #width: width,
      if (height != null) #height: height,
      if (size != null) #size: size,
      if (mime != null) #mime: mime,
      if (duration != null) #duration: duration,
      if (ext != null) #ext: ext,
      if (tags != null) #tags: tags,
    }),
  );
  @override
  MetadataEntryDto $make(CopyWithData data) => MetadataEntryDto(
    id: data.get(#id, or: $value.id),
    hash: data.get(#hash, or: $value.hash),
    width: data.get(#width, or: $value.width),
    height: data.get(#height, or: $value.height),
    size: data.get(#size, or: $value.size),
    mime: data.get(#mime, or: $value.mime),
    duration: data.get(#duration, or: $value.duration),
    ext: data.get(#ext, or: $value.ext),
    tags: data.get(#tags, or: $value.tags),
  );

  @override
  MetadataEntryDtoCopyWith<$R2, MetadataEntryDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MetadataEntryDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
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

