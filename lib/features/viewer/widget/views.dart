import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:hydrus_flutter/core/data/repo.dart';
import 'package:hydrus_flutter/core/ui/common.dart';
import 'package:hydrus_flutter/core/ui/images.dart';
import 'package:hydrus_flutter/core/domain/di/images.dart';
import 'package:hydrus_flutter/features/viewer/getx/transform.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import '../getx/page.dart';
import 'image_view.dart';


class ViewFile extends HookWidget {
  final int index;

  const ViewFile(this.index, {super.key});

  @override
  Widget build(_) {
    final file = Get.find<Images>()[index];

    final content = switch (file.type) {
      'image' => ViewImageX(index),
      'video' => ViewVideo(index),
      _ => _NotSupported(file.type),
    };

    final scrollAbove = useScrollController();
    final scrollBelow = useScrollController();

    return IgnorePointer(
      ignoring: false, // TODO переключать для активации/деактивации Dismissable
      child: SnappingSheet(
        controller: Get.find<SnappingSheetController>(),
        onSheetMoved: (positionData) {
          final page = Get.find<PageGetxController>();
          if (positionData.relativeToSheetHeight > 0) {
            page.block.value = true;
          } else {
            page.block.value = false;
          }
        },
        lockOverflowDrag: true,
        initialSnappingPosition: .factor(positionFactor: 0.0),
        snappingPositions: [
          .factor(positionFactor: 0.0),
          .factor(positionFactor: 0.5),
        ],
        grabbingHeight: 0,
        sheetAbove: SnappingSheetContent(
          draggable: true,
          child: content,
        ),
        sheetBelow: SnappingSheetContent(
          draggable: true,
          childScrollController: scrollBelow,
          child: Material(
            child: ListView.builder(
              itemCount: 21,
              controller: scrollBelow,
              itemBuilder: (context, index) => ListTile(title: Text('$index')),
            ),
          ),
        ),
      ),
    );
  }
}


class ObxHero extends StatelessWidget {
  final int index;
  final Object tag;
  final Widget child;

  const ObxHero({super.key, required this.index, required this.tag, required this.child});

  @override
  Widget build(BuildContext context) {
    final PageGetxController controller = Get.find();
    return Obx(() => HeroMode(
      enabled: controller.enabled(index),
      child: LinearHero(tag: tag, child: child),
    ));
  }
}



class ViewImage extends HookWidget {
  final int index;

  const ViewImage(this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    final image = Get.find<Images>()[index];

    final ticker = useSingleTickerProvider();
    final transform = useMemoized(() => TransformController(
      minScale: 1.0,
      zoomScale: 2.5,
      maxScale: 4.0,
      vsync: ticker,
    ));

    return GestureDetector(
      onDoubleTapDown: transform.handleDoubleTap,
      child: Obx(() => InteractiveViewer(
        minScale: transform.minScale,
        maxScale: transform.maxScale,
        panEnabled: !transform.blockViewer.value,
        transformationController: transform.controller,
        child: Center(
          child: ObxHero(
            index: index,
            tag: image.id,
            child: HighResImage(image: image),
          ),
        ),
      )),
    );
  }
}


class ViewVideo extends StatefulWidget {
  final int index;

  const ViewVideo(this.index, {super.key});

  @override
  State<ViewVideo> createState() => _ViewVideoState();
}

class _ViewVideoState extends State<ViewVideo> {

  late final player = Player(configuration: PlayerConfiguration())
    ..setVolume(0.0);
  late final controller = VideoController(player);

  final Images images = Get.find();
  final repo = Get.find<Repo>();
  final pageController = Get.find<PageGetxController>();

  bool ready = false;

  @override
  void initState() {
    super.initState();
    final id = images[widget.index].id;
    player.open(
      Media(repo.buildUrl(id)),
      play: pageController.enabled(widget.index),
    );
    player.stream.buffer.listen(playWhenLoaded);
    setPageChangeListener();
  }

  void playWhenLoaded(Duration d) {
    if (ready) return;
    if (d < Duration(milliseconds: 500)) return;
    setState(() => ready = true);
  }

  void setPageChangeListener() => ever(pageController.index, (i) {
    if (i == widget.index) {
      player.play();
    } else {
      player.pause();
      player.seek(Duration.zero);
    }
  });

  @override
  void dispose() async {
    super.dispose();
    await player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var video = images[widget.index];
    return Center(
      child: ObxHero(
        index: widget.index,
        tag: video.id,
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


class _NotSupported extends StatelessWidget {
  final String? type;

  const _NotSupported(this.type);

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