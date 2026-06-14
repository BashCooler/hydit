import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;


class AppPopScope extends StatelessWidget {
  final bool Function()? shouldShow;
  final Widget child;

  const AppPopScope({
    super.key,
    this.shouldShow,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: handle,
      child: child,
    );
  }

  void handle(bool didPop, Object? result) {
    if (didPop) return;

    final show = shouldShow?.call() ?? true;
    if (show) {
      Get.dialog(
        AppPopDialog(),
        transitionDuration: const Duration(milliseconds: 150),
      );
    }
  }
}


class AppPopDialog extends StatelessWidget {
  const AppPopDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: .center,
      icon: const Icon(Icons.close),
      title: 'Close application?'.n,
      actions: [
        n.Button('No'.n)
          ..onPressed = () => Get.back(),
        n.Button('Yes'.n)
          ..onPressed = () => SystemNavigator.pop(),
      ],
    );
  }
}