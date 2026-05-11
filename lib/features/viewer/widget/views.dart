import 'dart:async';

import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:hydrus_flutter/core/data/repo.dart';
import 'package:hydrus_flutter/core/ui/common.dart';
import 'package:hydrus_flutter/core/ui/images.dart';
import 'package:hydrus_flutter/core/domain/entities.dart';

import '../getx/page.dart';
import 'image_view.dart';


class ViewFile extends StatelessWidget {
  final int index;
  final HydrusFile file;
  final String tag;

  const ViewFile({
    super.key,
    required this.index,
    required this.tag,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    if (file.type != null) {
      return buildContent(file.type!);
    }
    return FutureBuilder(
      future: file.checkForMetadata(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == .done) {
          return buildContent(file.type!);
        } else {
          return const Center(
            child: ExpressiveLoadingIndicator(),
          );
        }
      },
    );
  }

  Widget buildContent(String type) {
    switch (type) {
      case 'image':
        return ViewImageX(index: index, file: file, tag: tag);
      case 'video':
        return ViewVideo(index: index, file: file, tag: tag);
      case _:
        return NotSupported(file.type);
    }
  }
}


class ObxHero extends StatelessWidget {
  final int index;
  final Object heroTag;
  final String getTag;
  final Widget child;

  const ObxHero({
    super.key,
    required this.index,
    required this.heroTag,
    required this.getTag,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final PageGetxController controller = Get.find(tag: getTag);
    return Obx(() => HeroMode(
      enabled: controller.enabled(index),
      child: LinearHero(tag: heroTag, child: child),
    ));
  }
}


class ViewVideo extends StatefulWidget {
  final int index;
  final String tag;
  final HydrusFile file;

  const ViewVideo({
    super.key,
    required this.index,
    required this.tag,
    required this.file,
  });

  @override
  State<ViewVideo> createState() => _ViewVideoState();
}

class _ViewVideoState extends State<ViewVideo> {
  late final player = Player(configuration: PlayerConfiguration())
    ..setVolume(0.0);
  late final controller = VideoController(player);

  final repo = Get.find<Repo>();
  late final PageGetxController pageController;

  StreamSubscription<Duration>? _bufferSubscription;
  Worker? _pageChangeWorker;
  bool _disposed = false;

  bool ready = false;

  @override
  void initState() {
    super.initState();
    pageController = Get.find(tag: widget.tag);
    unawaited(
      player.open(
        Media(repo.buildUrl(widget.file.id)),
        play: pageController.enabled(widget.index),
      ).catchError((_) {}),
    );
    _bufferSubscription = player.stream.buffer.listen(playWhenLoaded);
    setPageChangeListener();
  }

  void playWhenLoaded(Duration d) {
    if (ready) return;
    if (d < Duration(milliseconds: 500)) return;
    if (mounted) setState(() => ready = true);
  }

  void setPageChangeListener() {
    _pageChangeWorker = ever<int>(pageController.index, (i) {
      if (_disposed) return;
      if (i == widget.index) {
        _usePlayer(player.play);
      } else {
        _usePlayer(player.pause);
        _usePlayer(() => player.seek(Duration.zero));
      }
    });
  }

  void _usePlayer(Future<void> Function() action) {
    if (_disposed) return;
    try {
      unawaited(action().catchError((_) {}));
    } on AssertionError {
      // media_kit can assert if a late page-change
      // callback reaches a disposed player.
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _pageChangeWorker?.dispose();
    unawaited(_bufferSubscription?.cancel());
    unawaited(player.dispose().catchError((_) {}));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var video = widget.file;
    return Center(
      child: ObxHero(
        index: widget.index,
        heroTag: video.id,
        getTag: widget.tag,
        child: ImageStack(
          aspectRatio: video.width /video.height,
          children: [
            CachedNetworkImage(
              imageUrl: repo.buildUrl(video.id, thumbnail: true),
              placeholder: (context, url) => SizedBox.shrink(),
              fit: .cover,
            ),
            AnimatedOpacity(
              opacity: ready ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInQuint,
              child: Video(
                controller: controller,
                fill: Colors.transparent,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class NotSupported extends StatelessWidget {
  final String? type;

  const NotSupported(this.type, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: .center,
      spacing: 15,
      children: [
        Icon(Icons.image_not_supported_outlined, size: 96),
        Text('Media type "$type" is unsupported'),
      ],
    );
  }
}
