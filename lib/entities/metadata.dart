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

  String get type => mime.split('/').first;
  String get size => filesize(_size);
  String get res => '${width.toStringAsFixed(0)}x${height.toStringAsFixed(0)}';
}
