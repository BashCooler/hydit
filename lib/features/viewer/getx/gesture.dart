import 'package:get/get.dart';
import 'package:flutter/material.dart';


class GestureController {
  final _pointers = <int>{}.obs;

  final _zoom = false.obs;

  bool _stopped = false;

  bool get zoomed => _zoom.value;

  bool get pinch => _pointers.length > 1;

  bool get interacting => pinch || zoomed;

  Worker zoomWorker({required void Function(bool zoomed) callback}) {
    return ever(_zoom, callback);
  }

  void onZoomChanged(bool value) => _zoom.value = value;

  void onPointerDown(PointerDownEvent event) {
    _pointers.add(event.pointer);
  }

  void onPointerUp(PointerUpEvent event) {
    if (_stopped) return;
    _pointers.remove(event.pointer);
  }

  void onPointerCancel(PointerCancelEvent event) {
    if (_stopped) return;
    _pointers.remove(event.pointer);
  }

  /// Permanently stop tracking gestures.
  ///
  /// Call this before popping the current page to make sure the [Hero] works
  /// properly and not interrupted by the rebuild of the parent [PageView].
  void stop() => _stopped = true;
}
