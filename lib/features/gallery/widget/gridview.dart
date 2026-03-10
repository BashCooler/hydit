import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:hydrus_flutter/core/ui/widget/scroll_to_hide.dart';

import 'package:hydrus_flutter/core/data/hydrus.dart';
import 'package:hydrus_flutter/core/logic/entities.dart';
import 'package:hydrus_flutter/core/ui/widget/images.dart';
import 'package:hydrus_flutter/core/ui/getx/controllers.dart';
import 'package:hydrus_flutter/features/viewer/page/viewer.dart';
import '../getx/controllers.dart';


class ImageGridViewBuilder extends StatefulWidget {
  const ImageGridViewBuilder({super.key});

  @override
  State<ImageGridViewBuilder> createState() => _ImageGridViewBuilderState();
}

class _ImageGridViewBuilderState extends State<ImageGridViewBuilder> {
  final imageController = Get.find<Images>();
  final queryController = Get.find<QueryController>();
  final gridController = Get.find<GridObserverController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .symmetric(horizontal: 5.0),
      child: GridViewObserver(
        controller: gridController,
        child: RefreshIndicator(
          displacement: 100.0,
          onRefresh: () async => queryController.searchForFiles(),
          child: Obx(() => GridView.builder(
            physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            controller: gridController.controller,
            itemCount: imageController.images.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 5.0,
              crossAxisSpacing: 5.0,
            ),
            itemBuilder: (context, index) => _TileFutureBuilder(index),
          )),
        ),
      ),
    );
  }
}


class _TileFutureBuilder extends StatelessWidget {
  final int index;
  final client = Get.find<Client>();
  final imgCtrl = Get.find<Images>();

  _TileFutureBuilder(this.index);

  /// Save width and height to correctly display image in [PageView].
  ///
  /// See also: [HighResImage]
  void writeMetadata(Map<String, dynamic> metadata, HydrusImage image) {
    image.width = metadata['width'];
    image.height = metadata['height'];
    image.mime = metadata['mime'];
    image.duration = metadata['duration'];
    image.tags = metadata['tags'];
  }

  @override
  Widget build(BuildContext context) {
    final image = imgCtrl.images[index];

    if (image.width != -1) {
      return _Tile(index, image);
    }

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
          return _Tile(index, image);
        }
      },
    );
  }
}


class _Tile extends StatelessWidget {
  final int index;
  final HydrusImage image;

  const _Tile(this.index, this.image);

  @override
  Widget build(BuildContext context) {
    final badgeVisible = Get.find<QueryController>().badgeVisible;
    return GestureDetector(
      key: ValueKey(image.id),
      onTap: () {
        Get.find<ScrollToHideController>().hide();
        badgeVisible.value = false;
        Get.to(() => Viewer(index),
            transition: .fadeIn,
            curve: Curves.easeInCubic);
      },
      child: Stack(
        alignment: .bottomRight,
        children: [
          Hero(
            tag: image.id,
            createRectTween: (b, e) => RectTween(begin: b, end: e),
            child: Thumbnail(image),
          ),
          Obx(() => badgeVisible.value ? _TileBadges(image) : SizedBox.shrink()),
        ],
      ),
    );
  }
}


class _TileBadges extends StatelessWidget {
  final HydrusImage image;

  const _TileBadges(this.image);

  @override
  Widget build(BuildContext context) {
    final List<Widget> badges = [];
    if (image.duration > 0) {
      final duration = Duration(milliseconds: image.duration).toString();
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