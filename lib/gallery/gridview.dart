import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydrus_flutter/api/hydrus.dart';
import 'package:hydrus_flutter/viewer/viewer.dart';
import 'package:hydrus_flutter/viewer/images.dart';
import 'package:hydrus_flutter/gallery/services.dart';


class ImageGridViewBuilder extends StatefulWidget {
  const ImageGridViewBuilder({super.key});

  @override
  State<ImageGridViewBuilder> createState() => _ImageGridViewBuilderState();
}

class _ImageGridViewBuilderState extends State<ImageGridViewBuilder> {
  static const padding = 5.0;
  final client = Get.find<Client>();
  final imgCtrl = Get.find<Images>();
  
  final scrollCtrl = ScrollController();
  late final GridObserverController gridObserverCtrl;

  @override
  void initState() {
    super.initState();
    gridObserverCtrl = GridObserverController(controller: scrollCtrl);
    Get.put<GridObserverController>(gridObserverCtrl);
  }

  @override
  void dispose() {
    super.dispose();
    gridObserverCtrl.controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GridViewObserver(
        controller: gridObserverCtrl,
        child: GridView.builder(
          controller: scrollCtrl,
          itemCount: imgCtrl.images.length,
          padding: EdgeInsetsGeometry.all(5.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: padding,
            crossAxisSpacing: padding,
          ),
          itemBuilder: (context, index) => TileFutureBuilder(index),
        ),
      ),
    );
  }
}


class TileFutureBuilder extends StatelessWidget {
  final int index;
  final client = Get.find<Client>();
  final imgCtrl = Get.find<Images>();

  TileFutureBuilder(this.index, {super.key});

  /// Save width and height to correctly display image in [PageView].
  ///
  /// See also: [HighResImage]
  void writeMetadata(Map<String, dynamic> metadata, HydrusImage image) {
    image.width = metadata['width'];
    image.height = metadata['height'];
    image.mime = metadata['mime'];
    image.duration = metadata['duration'];
  }

  @override
  Widget build(BuildContext context) {
    final image = imgCtrl.images[index];
    return FutureBuilder(
      future: client.getFileMetadata(
        [image.id],
        includeServicesObject: false,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ColoredBox(color: Colors.white10);
        } else {
          writeMetadata(snapshot.data![0], image);
          return Tile(index, image);
        }
      },
    );
  }
}


class Tile extends StatelessWidget {
  final int index;
  final HydrusImage image;

  const Tile(this.index, this.image, {super.key});

  @override
  Widget build(BuildContext context) {
    final visibility = Get.find<SearchVisibility>();
    return GestureDetector(
      key: ValueKey(image.id),
      onTap: () {
        visibility.hide();
        Get.to(() => Viewer(index));
      },
      child: Stack(
        alignment: .bottomRight,
        children: [
          Hero(
            tag: image.id,
            createRectTween: (b, e) => RectTween(begin: b, end: e),
            child: Thumbnail(image),
          ),
          Obx(() => visibility.visible.value
              ? TileBadges(image)
              : const SizedBox.shrink()
          ),
        ],
      ),
    );
  }
}


class TileBadges extends StatelessWidget {
  final HydrusImage image;

  const TileBadges(this.image, {super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> badges = [];
    if (image.duration! > 0) {
      final duration = Duration(milliseconds: image.duration!).toString();
      final t = duration.split('.')[0].split(':');
      if (t[0] == '0') t.removeAt(0);
      badges.add(Text(t.join(':')));
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(mainAxisAlignment: .end, children: badges),
    );
  }
}