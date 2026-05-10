import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydrus_flutter/features/search/getx/query.dart';

import 'gallery.dart';
import 'selection.dart';

enum Mode { full, preview }


class GalleryBindings extends Bindings {
  final String tag;
  final Mode mode;

  GalleryBindings({required this.tag, required this.mode});

  @override
  void dependencies() {
    final scroll = ScrollController();
    final grid = GridObserverController(controller: scroll);

    final gallery = Get.put(GalleryController(grid: grid));

    if (mode == .preview) return;

    Get
      ..put(QueryController())
      ..put(SelectionController(gallery: gallery));
  }
}