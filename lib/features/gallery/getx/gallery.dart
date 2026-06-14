import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';


class GalleryController extends GetxController {
  bool _actionsLocked = false;
  final _actionsVisible = true.obs;
  final refreshing = false.obs;
  final _badgesVisible = true.obs;

  final GridObserverController grid;

  GalleryController()
      : grid = GridObserverController(controller: ScrollController());

  ScrollController get scroll => grid.controller!;
  bool get actionsVisible => _actionsVisible.value;
  bool get badgesVisible => _badgesVisible.value;

  @override
  void onInit() {
    super.onInit();
    scroll.addListener(listener);
  }

  void listener() {
    final direction = scroll.position.userScrollDirection;
    switch (direction) {
      case .forward:
        showActions();
      case .reverse:
        hideActions();
      case _:
        break;
    }
  }

  void hide() => this..hideActions()..hideBadges();

  void show() => this..showActions()..showBadges();

  void showActions() => _actionsLocked
      ? null
      : _actionsVisible.value = true;

  void hideActions() => _actionsLocked
      ? null
      : _actionsVisible.value = false;

  void lockActions() => _actionsLocked = true;

  void unlockActions() => _actionsLocked = false;

  void showBadges() => _badgesVisible.value = true;

  void hideBadges() => _badgesVisible.value = false;
}