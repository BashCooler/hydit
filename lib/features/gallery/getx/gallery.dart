import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


class GalleryController extends GetxController {
  final actionsVisible = true.obs;
  final refreshing = false.obs;

  final ScrollController scroll;

  GalleryController({required this.scroll});

  @override
  void onInit() {
    super.onInit();
    scroll.addListener(listener);
  }

  void listener() {
    final direction = scroll.position.userScrollDirection;
    if (direction == ScrollDirection.forward) {
      actionsVisible.value = true;
    } else if (direction == ScrollDirection.reverse) {
      actionsVisible.value = false;
    }
  }

  void show() => actionsVisible.value = true;
  void hide() => actionsVisible.value = false;
}