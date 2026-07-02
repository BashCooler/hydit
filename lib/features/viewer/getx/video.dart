import 'package:get/get.dart';
import 'package:hydit/features/viewer/getx/page.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/utils/utils.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';


class VideoGetxController extends GetxController {
  final String tag;

  VideoGetxController({required this.tag});

  final Player player = Player()
    ..setVolume(0);

  late final controller = VideoController(player);

  HydrusFile? _current;

  FileStore get files => Get.find(tag: tag);
  PageGetxController get page => Get.find(tag: tag);

  Future<void> load(String url) async => await player.open(
    Media(url),
    play: false,
  );

  Future<void> reset() async {
    await player.pause();
    await player.seek(Duration.zero);
  }

  @override
  void onInit() {
    super.onInit();
    ever(page.index, _onPageChanged);
    _onPageChanged(page.i);
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }

  Future<void> _onPageChanged(int index) async {
    final file = files[index];

    if (file.meta.type != 'video') {
      reset();
      return;
    }

    if (_current?.id != file.id) {
      _current = file;
    }

    await load(file.url);

    await player.seek(0.s);
    await player.play();
  }
}
