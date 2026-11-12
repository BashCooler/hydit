import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';


class VideoService {
  final Player player = Player()
    ..setVolume(0)
    ..setPlaylistMode(.single);

  late final controller = VideoController(player);
}
