import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_sheets/smooth_sheets.dart';


void main() => runApp(MaterialApp(theme: .dark(), home: SmoothExample()));


class SmoothExample extends StatefulWidget {
  const SmoothExample({super.key});

  @override
  State<SmoothExample> createState() => _SmoothExampleState();
}

class _SmoothExampleState extends State<SmoothExample> {

  @override
  void initState() {
    super.initState();
    Get.put<GetxSheetController>(
      GetxSheetController(
        footerHideInterval: (100.0, 200.0),
        inputHideInterval: (400.0, 600.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GetxSheetController>();
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color.fromARGB(255, 92, 92, 92),
      appBar: AppBar(title: Text('Sheet Example')),
      body: Stack(
        children: [
          const Center(child: Text("Основной контент приложения")),
          SearchSheet(
            scrollable: const Scrollable(),
            footer: const Material(child: ListTile(title: Text('Tag panel'))),
            footerHeight: 60.0,
            input: TextField(
              focusNode: controller.focusNode,
              decoration: const InputDecoration(filled: true),
            ),
            inputHeight: 60.0,
            snapPos: 200.0,
          ),
        ],
      ),
    );
  }
}

class SearchSheet extends StatelessWidget {
  final Widget scrollable;
  final Widget footer;
  final double footerHeight;
  final Widget input;
  final double inputHeight;
  final double snapPos;

  const SearchSheet({
    super.key,
    required this.scrollable,
    required this.footer,
    required this.footerHeight,
    required this.input,
    required this.inputHeight,
    required this.snapPos,
  });

  final handleSize = 30.0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GetxSheetController>();
    return NotificationListener<SheetNotification>(
      onNotification: controller.onNotification,
      child: SafeArea(
        child: ClipRect(
          child: SheetViewport(
            child: Sheet(
              shrinkChildToAvoidStaticOverlap: true,
              decoration: MaterialSheetDecoration(size: SheetSize.stretch),
              initialOffset: .absolute(snapPos),
              snapGrid: SheetSnapGrid(
                snaps: [
                  SheetOffset.absolute(handleSize),
                  SheetOffset.absolute(snapPos),
                  SheetOffset.proportionalToViewport(1.00),
                ],
              ),
              child: SheetContentScaffold(
                topBar: Handle(height: handleSize),
                body: Obx(() {
                  if (controller.offset.value < handleSize + 20.0) {
                    return SizedBox.shrink();
                  } else {
                    return Column(
                      mainAxisSize: .max,
                      children: [
                        Expanded(child: scrollable),
                        SizedBox(
                          height: footerHeight * controller.footerHeightMultiplier.value,
                          child: footer,
                        ),
                        controller.inputHeightMultiplier.value < 0.01 ? SizedBox.shrink() : SizedBox(
                          height: inputHeight * controller.inputHeightMultiplier.value,
                          child: input,
                        ),
                        SizedBox(height: controller.top.value),
                      ],
                    );
                  }
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class GetxSheetController extends GetxController {
  final (double, double) footerHideInterval;
  final (double, double) inputHideInterval;

  GetxSheetController({
    required this.footerHideInterval,
    required this.inputHideInterval,
  });

  final top = 0.0.obs;
  final offset = 0.0.obs;
  final footerHeightMultiplier = 1.0.obs;
  final inputHeightMultiplier = 0.0.obs;

  final focusNode = FocusNode();

  bool onNotification(SheetNotification n) {
    offset.value = n.metrics.offset;
    top.value = n.metrics.visibleRect?.top ?? top.value;

    inputHeightMultiplier.value = inverseLerp(
      inputHideInterval.$1,
      inputHideInterval.$2,
      offset.value,
    );

    footerHeightMultiplier.value = inverseLerp(
      footerHideInterval.$1,
      footerHideInterval.$2,
      offset.value,
    );

    return false;
  }
}


double inverseLerp(double a, double b, double value) {
  return clampDouble((value - a) / (b - a), 0.0, 1.0);
}


class Handle extends StatelessWidget {
  final double height;

  const Handle({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}


class Scrollable extends StatelessWidget {
  const Scrollable({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      shrinkWrap: true,
      itemCount: 20,
      itemBuilder: (ctx, index) => ListTile(
        leading: const Icon(Icons.history),
        title: Text("Подсказка поиска $index"),
      ),
    );
  }
}