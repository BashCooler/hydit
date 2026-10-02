import 'package:deep_pick/deep_pick.dart';
import 'package:filesize/filesize.dart';

import 'package:hydit/utils/utils.dart';


class FileMetadata {
  final int id;
  final String hash;
  final double width;
  final double height;
  final int sizeBytes;
  final String mime;
  final Duration duration;
  final String ext;

  const FileMetadata({
    required this.id,
    required this.hash,
    required this.width,
    required this.height,
    required this.sizeBytes,
    required this.mime,
    required this.duration,
    required this.ext,
  });

  /// The [map] parameter should be extracted from `file_metadata`
  /// response like so:
  ///
  /// `json -> metadata -> 0` (or other index)
  factory FileMetadata.fromMap(Map<String, dynamic> map) => FileMetadata(
    id: pick(map, 'file_id').asIntOrThrow(),
    hash: pick(map, 'hash').asStringOrThrow(),
    width: pick(map, 'width').asDoubleOr(0),
    height: pick(map, 'height').asDoubleOr(0),
    sizeBytes: pick(map, 'size').asIntOrThrow(),
    mime: pick(map, 'mime').asStringOrThrow(),
    duration: pick(map, 'duration').asMillisecondsOrZero(),
    ext: pick(map, 'ext').asStringOrThrow(),
  );

  /// The [pick] parameter should be extracted from `file_metadata`
  /// response like so:
  ///
  /// `pick(json, 'metadata', 0)` (or other index)
  factory FileMetadata.fromPick(Pick pick) {
    final map = pick.asMapOrThrow<String, dynamic>();

    return FileMetadata.fromMap(map);
  }

  String get fileName => '$hash$ext';
  String get type => mime.split('/').first;
  String get size => filesize(sizeBytes);
  String get res => '${width.toStringAsFixed(0)}x${height.toStringAsFixed(0)}';
  double get aspectRatio => width/height;
}


extension AsTypeOr on Pick {

  double asDoubleOr(double value) => asDoubleOrNull() ?? value;

  int asIntOr(int value) => asIntOrNull() ?? value;

  Duration asMillisecondsOrZero() => asIntOr(0).ms;
}
