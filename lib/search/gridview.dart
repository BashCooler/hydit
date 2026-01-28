import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:hydrus_flutter/search/search.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:hydrus_flutter/viewer/viewer.dart';

import '../api/hydrus.dart';
import '../main.dart';
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
        itemBuilder: (context, index) => Tile(index),
      ),
    );
  }
}


class Tile extends StatelessWidget {
  final int index;

  Tile(this.index, {super.key});

  final Client client = getIt<Client>();

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
          return GestureDetector(
            onTap: () {
              getIt<SearchVisibilityController>().hide();
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return Viewer(index: index);
              }));
            },
            child: Stack(
              children: [
                Hero(
                  tag: image.id,
                  createRectTween: (begin, end) {  // linear transition
                    return RectTween(begin: begin, end: end);
                  },
                  child: Thumbnail(image: image),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}


// MARK: METADATA

/// Save width and height to correctly display image in [PageView].
///
/// See also: [HighResImage]
void writeMetadata(Map<String, dynamic> metadata, HydrusImage image) {
  image.width = metadata['width'];
  image.height = metadata['height'];
  image.mime = metadata['mime'];
  image.duration = metadata['duration'];
}

