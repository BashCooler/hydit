import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydrus_flutter/core/domain/di/images.dart';
import 'package:hydrus_flutter/core/domain/entities.dart';
import 'package:hydrus_flutter/core/ui/images.dart';
import 'package:hydrus_flutter/features/viewer/widget/views.dart';

import '../getx/page.dart';


class ViewImage2 extends StatelessWidget {
  final int index;

  const ViewImage2(this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    final image = Get.find<Images>()[index];
    return _ZoomableImageView(
      key: ObjectKey(index),
      index: index,
      image: image,
    );
  }
}


class _ZoomableImageView extends StatefulWidget {
  final int index;
  final HydrusImage image;

  const _ZoomableImageView({
    super.key,
    required this.index,
    required this.image,
  });

  @override
  State<_ZoomableImageView> createState() => _ZoomableImageViewState();
}

class _ZoomableImageViewState extends State<_ZoomableImageView>
    with SingleTickerProviderStateMixin {

  static const double _minScale = 1.0;
  static const double _maxScale = 4.0;
  static const double _doubleTapScale = 2.5;
  static const double _elasticScaleFactor = 0.30;
  static const double _elasticOffsetFactor = 0.35;

  final Map<int, Offset> _pointers = {};
  final PageGetxController _pageController = Get.find();

  late final AnimationController _animationController;
  Animation<double>? _scaleAnimation;
  Animation<Offset>? _offsetAnimation;

  Size _viewportSize = Size.zero;
  Size _baseImageSize = Size.zero;

  Offset? _doubleTapPosition;

  double _scale = _minScale;
  Offset _offset = Offset.zero;

  Offset _panStartPoint = Offset.zero;
  Offset _panStartOffset = Offset.zero;

  double _pinchStartScale = _minScale;
  Offset _pinchStartOffset = Offset.zero;
  Offset _pinchStartFocal = Offset.zero;
  double _pinchStartDistance = 1.0;

  bool get _isZoomed => _scale > _minScale + 0.0001;
  Offset get _viewportCenter => _viewportSize.center(Offset.zero);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )
      ..addListener(_onAnimationFrame)
      ..addStatusListener(_onAnimationStatus);
  }

  @override
  void dispose() {
    _animationController
      ..removeListener(_onAnimationFrame)
      ..removeStatusListener(_onAnimationStatus)
      ..dispose();
    super.dispose();
  }

  void _onAnimationFrame() {
    final scale = _scaleAnimation?.value;
    final offset = _offsetAnimation?.value;
    if (scale == null || offset == null) return;
    setState(() {
      _scale = scale;
      _offset = offset;
    });
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _syncPageSwipeLock();
  }

  void _syncPageSwipeLock() {
    _pageController.zoom.value = _isZoomed;
  }

  void _stopAnimation() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
  }

  double _maxPanXFor(double scale) {
    final scaledWidth = _baseImageSize.width * scale;
    return max(0.0, (scaledWidth - _viewportSize.width) / 2);
  }

  double _maxPanYFor(double scale) {
    final scaledHeight = _baseImageSize.height * scale;
    return max(0.0, (scaledHeight - _viewportSize.height) / 2);
  }

  double _clampScale(double value) => value.clamp(_minScale, _maxScale).toDouble();

  Offset _clampOffset(Offset value, double scale) {
    final maxX = _maxPanXFor(scale);
    final maxY = _maxPanYFor(scale);
    return Offset(
      value.dx.clamp(-maxX, maxX).toDouble(),
      value.dy.clamp(-maxY, maxY).toDouble(),
    );
  }

  double _applyElasticScale(double value) {
    if (value < _minScale) {
      return _minScale + (value - _minScale) * _elasticScaleFactor;
    }
    if (value > _maxScale) {
      return _maxScale + (value - _maxScale) * _elasticScaleFactor;
    }
    return value;
  }

  Offset _applyElasticOffset(Offset value, double scale) {
    final maxX = _maxPanXFor(scale);
    final maxY = _maxPanYFor(scale);
    return Offset(
      _applyElasticBound(value.dx, -maxX, maxX),
      _applyElasticBound(value.dy, -maxY, maxY),
    );
  }

  double _applyElasticBound(double value, double min, double max) {
    if (value < min) {
      return min + (value - min) * _elasticOffsetFactor;
    }
    if (value > max) {
      return max + (value - max) * _elasticOffsetFactor;
    }
    return value;
  }

  Size _containedSize(Size imageSize, Size viewport) {
    if (imageSize.width <= 0 || imageSize.height <= 0) return viewport;
    final imageRatio = imageSize.width / imageSize.height;
    final viewportRatio = viewport.width / viewport.height;
    if (imageRatio > viewportRatio) {
      final width = viewport.width;
      return Size(width, width / imageRatio);
    }
    final height = viewport.height;
    return Size(height * imageRatio, height);
  }

  void _updateLayoutBounds(Size viewport) {
    final nextBaseSize = _containedSize(
      Size(widget.image.width.toDouble(), widget.image.height.toDouble()),
      viewport,
    );
    if (_viewportSize == viewport && _baseImageSize == nextBaseSize) return;
    _viewportSize = viewport;
    _baseImageSize = nextBaseSize;
    _scale = _clampScale(_scale);
    _offset = _clampOffset(_offset, _scale);
  }

  void _animateTo({
    required double scale,
    required Offset offset,
    bool enablePageSwipeImmediately = false,
  }) {
    final targetScale = _clampScale(scale);
    final targetOffset = _clampOffset(offset, targetScale);
    _scaleAnimation = Tween<double>(
      begin: _scale,
      end: targetScale,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _offsetAnimation = Tween<Offset>(
      begin: _offset,
      end: targetOffset,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    if (enablePageSwipeImmediately) {
      _syncPageSwipeLock();
    }
    _animationController.forward(from: 0);
  }

  void _onDoubleTapDown(TapDownDetails details) {
    _doubleTapPosition = details.localPosition;
  }

  void _onDoubleTap() {
    if (_viewportSize == Size.zero) return;
    _stopAnimation();
    if (_isZoomed) {
      _animateTo(
        scale: _minScale,
        offset: Offset.zero,
        enablePageSwipeImmediately: true,
      );
      return;
    }

    final tap = _doubleTapPosition ?? _viewportCenter;
    final targetScale = _doubleTapScale.clamp(_minScale, _maxScale);
    final local = (tap - _viewportCenter - _offset) / _scale;
    final targetOffset = _clampOffset(-local * targetScale, targetScale);
    _syncPageSwipeLock();
    _animateTo(scale: targetScale, offset: targetOffset);
  }

  void _onPointerDown(PointerDownEvent event) {
    _stopAnimation();
    _pointers[event.pointer] = event.localPosition;
    if (_pointers.length == 1) {
      _panStartPoint = event.localPosition;
      _panStartOffset = _offset;
      _syncPageSwipeLock();
      return;
    }
    if (_pointers.length == 2) {
      _syncPageSwipeLock();
      _setPinchStartValues();
    }
  }

  void _setPinchStartValues() {
    if (_pointers.length < 2) return;
    final points = _pointers.values.take(2).toList(growable: false);
    final focal = (points[0] + points[1]) / 2;
    _pinchStartScale = _scale;
    _pinchStartOffset = _offset;
    _pinchStartFocal = focal;
    _pinchStartDistance = max(1.0, (points[0] - points[1]).distance);
  }

  void _onPointerMove(PointerMoveEvent event) {
    final previous = _pointers[event.pointer];
    if (previous == null) return;
    _pointers[event.pointer] = event.localPosition;

    if (_pointers.length >= 2) {
      _syncPageSwipeLock();
      _updatePinch();
      return;
    }

    if (!_isZoomed) return;
    final rawOffset = _panStartOffset + (event.localPosition - _panStartPoint);
    final nextOffset = _applyElasticOffset(rawOffset, _scale);
    setState(() => _offset = nextOffset);
  }

  void _updatePinch() {
    final points = _pointers.values.take(2).toList(growable: false);
    if (points.length < 2) return;
    final focal = (points[0] + points[1]) / 2;
    final distance = max(1.0, (points[0] - points[1]).distance);

    final rawScale = _pinchStartScale * distance / _pinchStartDistance;
    final nextScale = _applyElasticScale(rawScale);
    final localAtStart = (_pinchStartFocal - _viewportCenter - _pinchStartOffset) / _pinchStartScale;
    final rawOffset = focal - _viewportCenter - localAtStart * nextScale;
    final nextOffset = _applyElasticOffset(rawOffset, nextScale);

    setState(() {
      _scale = nextScale;
      _offset = nextOffset;
    });
  }

  void _onPointerUp(PointerEvent event) {
    _pointers.remove(event.pointer);
    if (_pointers.length >= 2) {
      _setPinchStartValues();
      return;
    }
    if (_pointers.length == 1) {
      final remaining = _pointers.values.first;
      _panStartPoint = remaining;
      _panStartOffset = _offset;
      return;
    }
    _finalizeGesture();
  }

  void _finalizeGesture() {
    final clampedScale = _clampScale(_scale);
    final clampedOffset = _clampOffset(_offset, clampedScale);

    final needsSpringBack = (clampedScale - _scale).abs() > 0.0001 ||
        (clampedOffset - _offset).distance > 0.1;
    if (needsSpringBack) {
      _animateTo(scale: clampedScale, offset: clampedOffset);
      return;
    }

    setState(() {
      _scale = clampedScale;
      _offset = clampedOffset;
    });
    _syncPageSwipeLock();
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.image;
    return LayoutBuilder(
      builder: (_, constraints) {
        final viewport = constraints.biggest;
        _updateLayoutBounds(viewport);
        return ClipRect(
          child: Listener(
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerUp,
            child: GestureDetector(
              behavior: .opaque,
              onDoubleTapDown: _onDoubleTapDown,
              onDoubleTap: _onDoubleTap,
              child: Center(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..translate(_offset.dx, _offset.dy)
                    ..scale(_scale),
                  child: SizedBox(
                    width: _baseImageSize.width,
                    height: _baseImageSize.height,
                    child: ObxHero(
                      index: widget.index,
                      tag: image.id,
                      child: HighResImage(image: image),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
