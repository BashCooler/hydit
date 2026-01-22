import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hydrus_flutter/hydrus_api/hydrus.dart';
import 'package:hydrus_flutter/widgets/images.dart';

// TODO double tap zoom, drag to close

class ImageView extends StatefulWidget {
  final List<HydrusImage> images;
  final int index;
  final Client client;

  const ImageView({
    super.key,
    required this.images,
    required this.index,
    required this.client,
  });

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  late final PageController _pageController;

  bool _isNotZoomed = true;
  final _transformationController = TransformationController();
  double get _interactiveViewerScale => _transformationController.value.row0.x;

  final List<int> _pointerEvents = [];
  bool _isMultitouch = false;

  /// Takes details of [PointerDownEvent] or [PointerUpEvent].
  /// Adds/removes the event to/from the [List] of type [int].
  /// Determines whether a multitouch is being used, updates
  /// the [bool] [_isMultitouch] variable with [SetState].
  void registerPointerEventState(Object details) {
    if (details is PointerDownEvent) {
      _pointerEvents.add(details.pointer);
    }
    if (details is PointerUpEvent) {
      _pointerEvents.remove(details.pointer);
    }
    if (!_isNotZoomed) return;

    final newValue = _pointerEvents.length > 1;
    if (newValue != _isMultitouch) {
      setState(() => _isMultitouch = newValue);
    }
  }

  void updateZoomState(ScaleUpdateDetails details) {
    final newValue = _interactiveViewerScale <= 1.0;
    if (_isNotZoomed != newValue) {
      setState(() => _isNotZoomed = newValue);
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index);
  }

  @override
  void dispose() {
    super.dispose();
    _transformationController.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Listener(
        onPointerDown: registerPointerEventState,
        onPointerUp: registerPointerEventState,
        child: PageView.builder(
          physics: (_isNotZoomed && !_isMultitouch)
              ? const PageScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          controller: _pageController,
          itemCount: widget.images.length,
          itemBuilder: (context, i) {
            return InteractiveViewer(
              transformationController: _transformationController,
              onInteractionUpdate: updateZoomState,
              child: Center(
                child: Hero(
                  tag: widget.images[i].id,
                  createRectTween: (begin, end) {  // linear transition
                    return RectTween(begin: begin, end: end);
                  },
                  child: HighResImage(
                    image: widget.images[i],
                    client: widget.client,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        // Swipe doesn't work on Windows for some reason so I added buttons
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            IconButton(
              onPressed: () => _pageController.previousPage(
                duration: Duration(milliseconds: 150),
                curve: Curves.decelerate,
              ),
              icon: Icon(Icons.keyboard_arrow_left),
            ),
            IconButton(
              onPressed: () => _pageController.nextPage(
                duration: Duration(milliseconds: 150),
                curve: Curves.decelerate,
              ),
              icon: Icon(Icons.keyboard_arrow_right),
            ),
          ],
        ),
      ),
    );
  }
}
