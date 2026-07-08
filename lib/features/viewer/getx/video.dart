import 'dart:async';

import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'page.dart';
import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/services/video.dart';


class VideoGetxController extends GetxController {
  final String tag;

  VideoGetxController({required this.tag});

  VideoService get service => Get.find();

  Player get player => service.player;

  VideoController get controller => service.controller;

  HydrusFile? _current;

  StreamSubscription<Duration>? _buffer;

  final _ready = false.obs;
  bool get ready => _ready.value;

  PageGetxController get page => Get.find(tag: tag);

  late final Worker _worker;

  @override
  void onInit() {
    super.onInit();

    _worker = ever(page.index, _onPageChanged);
    _onPageChanged(page.i);

    _buffer = player.stream.buffer
        .listen(_onBufferUpdate);
  }

  @override
  void onClose() {
    player.stop();
    _buffer?.cancel();
    _worker.dispose();
    super.onClose();
  }

  Future<void> load(String url) async {
    _ready.value = false;
    await player.open(Media(url), play: false);
  }

  Future<void> reset() async {
    await player.pause();
    await player.seek(Duration.zero);
  }

  Future<void> _onPageChanged(int index) async {
    final file = page.files[index];

    if (file.meta.type != 'video') {
      reset();
      return;
    }

    if (_current?.id != file.id) {
      _current = file;
    }

    await load(file.url);

    await player.seek(.zero);
    await player.play();
  }

  void _onBufferUpdate(Duration buffer) {
    if (_ready.value) return;
    if (buffer < 500.ms) return;

    _ready.value = true;
    player.play();
  }
}
