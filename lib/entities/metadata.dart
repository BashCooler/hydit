import 'package:deep_pick/deep_pick.dart';
import 'package:filesize/filesize.dart';


class FileMetadata {
  final int id;
  final double width;
  final double height;
  final int _size;
  final String mime;
  final Duration duration;

  FileMetadata({
    required this.id,
    required this.width,
    required this.height,
    required this._size,
    required this.mime,
    required int duration,
  })
      : duration = Duration(milliseconds: duration);

  /// The [map] parameter should be extracted from `file_metadata`
  /// response like so:
  ///
  /// `json -> metadata -> 0` (or other index)
  factory FileMetadata.fromMap(Map<String, dynamic> map) => .new(
    id: pick(map, 'file_id').asIntOrThrow(),
    width: pick(map, 'width').asDoubleOr(0),
    height: pick(map, 'height').asDoubleOr(0),
    size: pick(map, 'size').asIntOrThrow(),
    mime: pick(map, 'mime').asStringOrThrow(),
    duration: pick(map, 'duration').asIntOr(0),
  );

  String get type => mime.split('/').first;
  String get size => filesize(_size);
  String get res => '${width.toStringAsFixed(0)}x${height.toStringAsFixed(0)}';
  double get aspectRatio => width/height;
}


extension AsTypeOr on Pick {

  double asDoubleOr(double value) => asDoubleOrNull() ?? value;

  int asIntOr(int value) => asIntOrNull() ?? value;
}
