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

  static Map<String, Map<String, TagRelations>> _$tags(
    SiblingsAndParentsDto v,
  ) => v.tags;
  static const Field<
    SiblingsAndParentsDto,
    Map<String, Map<String, TagRelations>>
  >
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
    String,
    Map<String, TagRelations>,
    ObjectCopyWith<$R, Map<String, TagRelations>, Map<String, TagRelations>>
  >
  get tags;
  $R call({Map<String, Map<String, TagRelations>>? tags});
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
    String,
    Map<String, TagRelations>,
    ObjectCopyWith<$R, Map<String, TagRelations>, Map<String, TagRelations>>
  >
  get tags => MapCopyWith(
    $value.tags,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(tags: v),
  );
  @override
  $R call({Map<String, Map<String, TagRelations>>? tags}) =>
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
    }
    return _instance!;
  }

  @override
  final String id = 'TagRelations';

  static String _$ideal(TagRelations v) => v.ideal;
  static const Field<TagRelations, String> _f$ideal = Field(
    'ideal',
    _$ideal,
    key: r'ideal_tag',
  );
  static List<String> _$descendants(TagRelations v) => v.descendants;
  static const Field<TagRelations, List<String>> _f$descendants = Field(
    'descendants',
    _$descendants,
  );

  @override
  final MappableFields<TagRelations> fields = const {
    #ideal: _f$ideal,
    #descendants: _f$descendants,
  };

  static TagRelations _instantiate(DecodingData data) {
    return TagRelations(
      ideal: data.dec(_f$ideal),
      descendants: data.dec(_f$descendants),
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
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get descendants;
  $R call({String? ideal, List<String>? descendants});
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
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get descendants => ListCopyWith(
    $value.descendants,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(descendants: v),
  );
  @override
  $R call({String? ideal, List<String>? descendants}) => $apply(
    FieldCopyWithData({
      if (ideal != null) #ideal: ideal,
      if (descendants != null) #descendants: descendants,
    }),
  );
  @override
  TagRelations $make(CopyWithData data) => TagRelations(
    ideal: data.get(#ideal, or: $value.ideal),
    descendants: data.get(#descendants, or: $value.descendants),
  );

  @override
  TagRelationsCopyWith<$R2, TagRelations, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TagRelationsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

