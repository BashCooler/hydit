import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:flutter_inner_drawer/inner_drawer.dart';


class AppShell extends StatefulWidget {
  final Widget? sidebar;
  final bool Function()? dialog;
  final Widget child;

  const AppShell({
    super.key,
    this.dialog,
    this.sidebar,
    required this.child,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final drawerKey = GlobalKey<InnerDrawerState>();

  bool drawerOpened = false;

  void handlePop(bool didPop, Object? result) {
    if (didPop) return;

    if (drawerOpened) {
      drawerKey.currentState?.toggle();
      return;
    }

    if (widget.dialog?.call() ?? true) {
      Get.dialog(
        AppPopDialog(),
        transitionDuration: const Duration(milliseconds: 150),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: handlePop,
      child: InnerDrawer(
        key: drawerKey,
        onTapClose: true,
        swipeChild: true,
        rightAnimationType: .quadratic,
        innerDrawerCallback: (opened, _) {
          drawerOpened = opened;
        },
        scaffold: widget.child,
        rightChild: widget.sidebar,
      ),
    );
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
