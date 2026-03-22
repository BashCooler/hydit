import 'package:get/get.dart';
import 'package:flutter/material.dart';


class TransformController extends GetxController {
  bool _zoom = false;
  bool get block => _zoom || _pinch;

  final double minScale;
  final double maxScale;

  final _pointers = RxSet<int>();
  bool get _pinch => _pointers.length > 1;

  final controller = TransformationController();
  TransformationController get $ => controller;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  TransformController({
    required this.minScale,
    required this.maxScale,
    required TickerProvider vsync,
  }) {
    _animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 150),
    )..addListener(_setMatrix);
    controller.addListener(_onMatrixChange);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    _animationController.dispose();
  }

  void registerPointer(Object details) {
    if (details is PointerDownEvent) _pointers.add(details.pointer);
    if (details is PointerUpEvent) _pointers.remove(details.pointer);
  }

  void _setMatrix() {
    controller.value = _animation?.value ?? Matrix4.identity();
  }

  void _onMatrixChange() {
    _zoom = controller.value.row0.x > minScale + 0.1;
  }

  void handleDoubleTap(TapDownDetails details) {
    final pos = details.localPosition;
    var mat = controller.value.clone();

    final scale = mat.row0.x;
    double target = (scale <= minScale) ? maxScale : minScale;
    _zoom = target > minScale;

    final double offsetX = target == minScale
        ? 0.0
        : -pos.dx * (target - 1);
    final double offsetY = target == minScale
        ? 0.0
        : -pos.dy * (target - 1);

    _zoom = offsetX != 0.0;

    mat = getTargetMatrix(target, mat, offsetX, offsetY);

    _animation = Matrix4Tween(
      begin: controller.value,
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