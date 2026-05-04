import 'package:get/get.dart';
import 'package:flutter/material.dart';


class GalleryController extends GetxController {
  bool _actionsLocked = false;
  final _actionsVisible = true.obs;
  final refreshing = false.obs;

  final ScrollController scroll;

  GalleryController({required this.scroll});

  bool get actionsVisible => _actionsVisible.value;

  @override
  void onInit() {
    super.onInit();
    scroll.addListener(listener);
  }

  void listener() {
    final direction = scroll.position.userScrollDirection;
    switch (direction) {
      case .forward:
        show();
      case .reverse:
        hide();
      case _:
        break;
    }
  }

  void show() => _actionsLocked ? null : _actionsVisible.value = true;
  void hide() => _actionsLocked ? null : _actionsVisible.value = false;
  void lock() => _actionsLocked = true;
  void unlock() => _actionsLocked = false;
}