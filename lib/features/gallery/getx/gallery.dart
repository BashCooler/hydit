import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';


class GalleryController extends GetxController {
  final refreshing = false.obs;
  final _badgesVisible = true.obs;

  final GridObserverController grid;

  GalleryController()
      : grid = GridObserverController(controller: ScrollController());

  ScrollController get scroll => grid.controller!;

  bool get badgesVisible => _badgesVisible.value;

  void scrollUp() {
    scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInCubic,
    );
  }

  void show() => _badgesVisible.value = true;

  void hide() => _badgesVisible.value = false;
}


extension Delay on void Function() {
  void Function() delayed(Duration duration) {
    return () => Future.delayed(duration, this);
  }
}
