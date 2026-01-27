import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydrus_flutter/viewer/viewer.dart';
import '../main.dart';
import '../viewer/images.dart';


class ImageGridViewBuilder extends StatefulWidget with WatchItStatefulWidgetMixin {
  const ImageGridViewBuilder({super.key});

  @override
  State<ImageGridViewBuilder> createState() => _ImageGridViewBuilderState();
}

class _ImageGridViewBuilderState extends State<ImageGridViewBuilder> {
  final padding = 5.0;

  final client = getIt<GetClient>().client;

  final scrollController = ScrollController();
  late GridObserverController observerController;

  @override
  void initState() {
    super.initState();
    observerController = GridObserverController(controller: scrollController);
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
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              getIt<SearchVisibilityController>().hide();
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return Viewer(
                  images: images,
                  index: index,
                  observerController: observerController,
                );
              }));
            },
            child: Hero(
              tag: images[index].id,
              createRectTween: (begin, end) {  // linear transition
                return RectTween(begin: begin, end: end);
              },
              child: Thumbnail(image: images[index]),
            ),
          );
        },
      ),
    );
  }
}