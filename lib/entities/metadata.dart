import 'package:hydit/api/models.dart';


class const FileMetadata({
  required final int id,
  required final String hash,
  required final double width,
  required final double height,
  required final int size,
  required final String mime,
  required final Duration duration,
  required final String ext,
}) {
  factory fromDto(FileMetadataDto dto) => FileMetadata(
    id: dto.id,
    hash: dto.hash,
    width: dto.width,
    height: dto.height,
    size: dto.size,
    mime: dto.mime,
    duration: dto.duration,
    ext: dto.ext,
  );

  String get type => mime.split('/').first;
  String get res => '${width.toStringAsFixed(0)}x${height.toStringAsFixed(0)}';
  double get aspectRatio => width/height;
}
