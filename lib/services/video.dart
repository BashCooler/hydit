import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';


class VideoService extends GetxController {
  final Player player = Player()
    ..setVolume(0);

  late final controller = VideoController(player);

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
