import 'package:get/get.dart';
import 'package:flutter/material.dart';


class GestureController {
  final _pointers = <int>{}.obs;

  final _zoom = false.obs;

  bool get zoom => _zoom.value;

  bool get pinch => _pointers.length > 1;

  bool get interacting => pinch || zoom;

  void onZoomChanged(bool value) => _zoom.value = value;

  void registerPointer(Object details) {
    if (details is PointerDownEvent) _pointers.add(details.pointer);
    if (details is PointerUpEvent) _pointers.remove(details.pointer);
  }
}
