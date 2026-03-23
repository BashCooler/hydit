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

    final mat = getTargetMatrix(target, $.value.clone(), offsetX, offsetY);

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


/// Returns target transformation matrix.
///
/// Initial transformation matrix is an identity matrix.
///
/// Target matrix with 4x scale and X1=-500, Y1=-800 offset:
/// ```
/// 4 0 0 -500
/// 0 4 0 -800
/// 0 0 4 0
/// 0 0 0 1
/// ```
Matrix4 getTargetMatrix(double scale, Matrix4 mat, double offsetX, double offsetY) {
  return Matrix4.fromList([
    // Column 1
    scale,  // scale X
    mat.row1.x,
    mat.row2.x,
    mat.row3.x,
    // Column 2
    mat.row0.y,
    scale,  // scale Y
    mat.row2.y,
    mat.row3.y,
    // Column 3
    mat.row0.z,
    mat.row1.z,
    scale,  // scale Z
    mat.row3.z,
    // Column 4
    offsetX,      // translate X1
    offsetY,      // translate Y1
    mat.row2.w,
    mat.row3.w,
  ]);
}