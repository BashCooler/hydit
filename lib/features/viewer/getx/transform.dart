import 'package:get/get.dart';
import 'package:flutter/material.dart';


class TransformController extends GetxController {
  final blockScroll = false.obs;
  final blockViewer = false.obs;
  final _pointers = RxSet<int>();

  final double minScale;
  final double maxScale;

  final controller = TransformationController();
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  bool get _pinch => _pointers.length > 1;
  bool get _zoom => scale > minScale + 0.1;
  bool get noScroll => blockScroll.value;
  double get scale => controller.value.row0.x;

  TransformationController get $ => controller;

  TransformController({
    required this.minScale,
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
  void onInit() {
    super.onInit();
    ever(_pointers, _everPointers);
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

  void registerPointer(Object details) {
    if (details is PointerDownEvent) _pointers.add(details.pointer);
    if (details is PointerUpEvent) _pointers.remove(details.pointer);
  }

  void _everPointers(Set<int> callback) {
    _updateBlockScroll();
  }

  void _updateBlockScroll() {
    blockScroll.value = _zoom || _pinch;
  }

  void _onMatrixChange() => _updateBlockScroll();

  void handleDoubleTap(TapDownDetails details) {
    final pos = details.localPosition;

    final target = (scale <= minScale) ? maxScale : minScale;

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