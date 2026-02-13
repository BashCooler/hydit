import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';


class MultitouchController extends GetxController {
  final Set<int> _pointers = {};

  final multitouch = false.obs;

  void register(Object details) {
    if (details is PointerDownEvent) _pointers.add(details.pointer);
    if (details is PointerUpEvent) _pointers.remove(details.pointer);
    multitouch.value = _pointers.length > 1;
  }
}


class ZoomController extends GetxController {
  final double minScale = 1.0;
  final double maxScale = 4.0;
  final transformationCtrl = TransformationController();

  late AnimationController _animationCtrl;
  Animation<Matrix4>? _animation;

  final zoomed = false.obs;

  ZoomController({required TickerProvider vsync}) {
    _animationCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 150),
    )..addListener(() {
      // listen matrix4 changed, if not, set as default value
      transformationCtrl.value = _animation?.value ?? Matrix4.identity();
    });
    transformationCtrl.addListener(_onMatrixChange);
  }

  @override
  void dispose() {
    super.dispose();
    transformationCtrl.dispose();
    _animationCtrl.dispose();
  }

  void _onMatrixChange() {
    zoomed.value = transformationCtrl.value.row0.x > minScale + 0.1;
  }

  void handleDoubleTap(Offset localPos) {
    var mat = transformationCtrl.value.clone();

    final curScale = mat.row0.x;
    double targetScale = (curScale <= minScale) ? maxScale : minScale;

    zoomed.value = targetScale > minScale;

    final double offSetX = targetScale == minScale
        ? 0.0
        : -localPos.dx * (targetScale - 1);
    final double offSetY = targetScale == minScale
        ? 0.0
        : -localPos.dy * (targetScale - 1);

    mat = getTargetMatrix(targetScale, mat, offSetX, offSetY);

    _animation = Matrix4Tween(
      begin: transformationCtrl.value,
      end: mat,
    ).animate(
        CurvedAnimation(
          parent: _animationCtrl,
          curve: Curves.easeOut,
        )
    );
    _animationCtrl.forward(from: 0);
  }
}


class PageViewController extends GetxController {
  final int initialIndex;
  final PageController controller;
  final observerController = Get.find<GridObserverController>();

  final RxInt currentIndex;

  PageViewController({required this.initialIndex})
      : currentIndex = initialIndex.obs,
        controller = PageController(initialPage: initialIndex);

  void onPageChanged(int page) {
    currentIndex.value = page;
    jumpToPageInBackground(page);
  }

  /// Jumps to corresponding item in [GridView].
  ///
  /// Example: you open item `0` in the [GridView], then scroll to file `40`
  /// using [PageView]. [jumpToPageInBackground] scrolls to picture `40` in
  /// the background to lazy load new thumbnails and so when you close
  /// [PageView] you end up seeing item `40`, not `0`.
  ///
  /// TODO `-2` in `page - 2` is a tech debt!
  /// If [SliverGridDelegateWithFixedCrossAxisCount.crossAxisCount] changed
  /// in settings the `-2` offset becomes irrelevant
  void jumpToPageInBackground(int page) {
    observerController.jumpTo(index: page - 2 > 0 ? page - 2 : 0);
  }
}


// MARK: TARGET MATRIX

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
Matrix4 getTargetMatrix(double targetScale, Matrix4 mat, double offSetX, double offSetY) {
  return Matrix4.fromList([
    // Column 1
    targetScale,  // scale X
    mat.row1.x,
    mat.row2.x,
    mat.row3.x,
    // Column 2
    mat.row0.y,
    targetScale,  // scale Y
    mat.row2.y,
    mat.row3.y,
    // Column 3
    mat.row0.z,
    mat.row1.z,
    targetScale,  // scale Z
    mat.row3.z,
    // Column 4
    offSetX,      // translate X1
    offSetY,      // translate Y1
    mat.row2.w,
    mat.row3.w,
  ]);
}