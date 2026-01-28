import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:hydrus_flutter/search/search.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:hydrus_flutter/viewer/viewer.dart';

import '../api/hydrus.dart';
import '../main.dart';
import '../settings/theme.dart';
import '../viewer/images.dart';


class ImageGridViewBuilder extends StatefulWidget with WatchItStatefulWidgetMixin {
  const ImageGridViewBuilder({super.key});

  @override
  State<ImageGridViewBuilder> createState() => _ImageGridViewBuilderState();
}

class _ImageGridViewBuilderState extends State<ImageGridViewBuilder> {
  final padding = 5.0;

  final client = getIt<Client>();

  final scrollController = ScrollController();
  final observerController = getIt<GridObserverController>();

  @override
  void initState() {
    super.initState();
    observerController.controller = scrollController;
  }

  @override
  void dispose() {
    scrollController.dispose();
    observerController.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = watchIt<GetImages>().value;
    return GridViewObserver(
      controller: observerController,
      child: GridView.builder(
        controller: scrollController,
        itemCount: images.length,
        padding: EdgeInsetsGeometry.all(padding),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: padding,
          crossAxisSpacing: padding,
        ),
        itemBuilder: (context, index) => TileFutureBuilder(index),
      ),
    );
  }
}


class TileFutureBuilder extends StatelessWidget {
  final int index;

  TileFutureBuilder(this.index, {super.key});

  final Client client = getIt<Client>();

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
    final HydrusImage image = getIt<GetImages>().value[index];
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
          return Tile(index: index, image: image);
        }
      },
    );
  }
}


class Tile extends StatelessWidget with WatchItMixin {
  const Tile({
    super.key,
    required this.index,
    required this.image,
  });

  final int index;
  final HydrusImage image;

  @override
  Widget build(BuildContext context) {
    final visible = watchIt<SearchVisibility>().value;
    return GestureDetector(
      onTap: () {
        getIt<SearchVisibility>().hide();
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return Viewer(index: index);
        }));
      },
      child: Stack(
        alignment: .bottomRight,
        children: [
          Hero(
            tag: image.id,
            createRectTween: (begin, end) {  // linear transition
              return RectTween(begin: begin, end: end);
            },
            child: Thumbnail(image: image),
          ),
          visible ? TileBadges(image) : SizedBox.shrink(),
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
