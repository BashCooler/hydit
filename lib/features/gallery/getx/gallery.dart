import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'package:hydit/utils/utils.dart';


class GalleryController extends GetxController {
  final loading = false.obs;
  final _visible = true.obs;

  final GridObserverController grid;

  GalleryController()
      : grid = GridObserverController(controller: ScrollController());

  ScrollController get scroll => grid.controller!;

  bool get badges => _visible.value;

  void scrollUp() {
    scroll.animateTo(0, duration: 500.ms, curve: Curves.easeInCubic);
  }

  void show() => _visible.value = true;

  void hide() => _visible.value = false;
}
