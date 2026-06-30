import 'dart:convert';

import 'package:deep_pick/deep_pick.dart';

import 'package:hydit/entities/tags.dart';
import 'package:hydit/entities/metadata.dart';
import 'package:hydit/reactive/file.dart';


class Mapper {
  Mapper._();

  static void writeMetadata(String rawJson, HydrusFile image) {
    final json = jsonDecode(rawJson);
    Pick meta = pick(json, 'metadata', 0);

    final metadata = FileMetadata(
      width: meta('width').asDoubleOrNull() ?? 0,
      height: meta('height').asDoubleOrNull() ?? 0,
      size: meta('size').asIntOrThrow(),
      mime: meta('mime').asStringOrThrow(),
      duration: meta('duration').asIntOrNull() ?? 0,
      combined: {}, // TODO remove this field
    );

    image.metadata.value = metadata;

    final tags = meta('tags').asMapOrThrow<String, dynamic>();
    image.tags.value = Tags.fromMap(tags);
  }
}


extension Parsers on String {

  Pick pick([
    Object? arg0,
    Object? arg1,
    Object? arg2,
    Object? arg3,
    Object? arg4,
    Object? arg5,
    Object? arg6,
    Object? arg7,
    Object? arg8,
    Object? arg9,
  ]) {
    return pickDeep(this, [
      ?arg0,
      ?arg1,
      ?arg2,
      ?arg3,
      ?arg4,
      ?arg5,
      ?arg6,
      ?arg7,
      ?arg8,
      ?arg9,
    ]);
  }

  dynamic decode() => jsonDecode(this);
}


extension AssignAll<K, V> on Map<K, V> {
  void assignAll(Map<K, V> map) => this..clear()..addAll(map);
}
