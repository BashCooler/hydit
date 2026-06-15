import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;


class AppPopScope extends StatelessWidget {
  final bool Function()? showDialog;
  final Widget child;
  final bool canPop;

  const AppPopScope({
    super.key,
    this.showDialog,
    this.canPop = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: handle,
      child: child,
    );
  }

  void handle(bool didPop, Object? result) {
    if (didPop) return;

    final show = showDialog?.call() ?? true;
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