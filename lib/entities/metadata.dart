import 'package:deep_pick/deep_pick.dart';
import 'package:filesize/filesize.dart';


class FileMetadata {
  final double width;
  final double height;
  final int _size;
  final String mime;
  final Duration duration;

  FileMetadata({
    required this.width,
    required this.height,
    required this._size,
    required this.mime,
    required int duration,
  })
      : duration = Duration(milliseconds: duration);

  factory FileMetadata.fromMap(Map<String, dynamic> metadataEntry) {

    return FileMetadata(
      width: pick(metadataEntry, 'width').asDoubleOrNull() ?? 0,
      height: pick(metadataEntry, 'height').asDoubleOrNull() ?? 0,
      size: pick(metadataEntry, 'size').asIntOrThrow(),
      mime: pick(metadataEntry, 'mime').asStringOrThrow(),
      duration: pick(metadataEntry, 'duration').asIntOrNull() ?? 0,
    );
  }

  String get type => mime.split('/').first;
  String get size => filesize(_size);
  String get res => '${width.toStringAsFixed(0)}x${height.toStringAsFixed(0)}';
  double get aspectRatio => width/height;
}
