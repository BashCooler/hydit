import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydrus_flutter/features/viewer/getx/page.dart';


class TransformController extends GetxController {
  final blockViewer = false.obs;

  final double minScale;
  final double zoomScale;
  final double maxScale;

  final controller = TransformationController();
  final page = Get.find<PageGetxController>();

  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  bool get _zoom => scale > minScale + 0.1;
  double get scale => controller.value.row0.x;

  TransformationController get $ => controller;

  TransformController({
    required this.minScale,
    required this.zoomScale,
    required this.maxScale,
    required TickerProvider vsync,
  }) {
    _animationController = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 150))
      ..addListener(_onAnimationFrame)
      ..addStatusListener(_onStatusUpdate);
    controller.addListener(_onMatrixChange);
  }

  @override
  void dispose() {
    controller.dispose();
    _animationController
      ..removeListener(_onAnimationFrame)
      ..removeStatusListener(_onStatusUpdate)
      ..dispose();
    super.dispose();
  }

  void _onAnimationFrame() {
    controller.value = _animation?.value ?? Matrix4.identity();
  }

  /// Block pan gestures during animation
  void _onStatusUpdate(AnimationStatus status) {
    switch (status) {
      case .forward:
        blockViewer.value = true;
      case .completed:
        blockViewer.value = false;
      case _:
    }
  }

  void _onMatrixChange() => page.zoom.value = _zoom;

  void handleDoubleTap(TapDownDetails details) {
    final pos = details.localPosition;

    final target = (scale <= minScale) ? zoomScale : minScale;

    final offsetX = target == minScale
        ? 0.0
        : -pos.dx * (target - 1);
    final offsetY = target == minScale
        ? 0.0
        : -pos.dy * (target - 1);

    final Matrix4 mat = .identity()
      ..translateByDouble(offsetX, offsetY, 1, 1)
      ..scaleByDouble(target, target, target, 1);

    _animation = Matrix4Tween(
      begin: $.value,
      end: mat,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward(from: 0);
  }
}