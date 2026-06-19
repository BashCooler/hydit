import 'package:flutter/material.dart';


class ConfirmDialog extends StatelessWidget {
  final Icon icon;
  final Widget message;
  final ValueNotifier<bool> loading;
  final Widget loadingTitle;
  final Widget title;
  final List<Widget> actions;

  const ConfirmDialog({
    super.key,
    required this.icon,
    required this.message,
    required this.loading,
    required this.loadingTitle,
    required this.title,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (loading.value) return;
        Navigator.of(context).pop();
      },
      child: ValueListenableBuilder(
        valueListenable: loading,
        builder: (context, value, child) {
          return AlertDialog(
            actionsAlignment: .center,
            icon: icon,
            title: loading.value ? loadingTitle : title,
            content: loading.value
                ? const LinearProgressIndicator()
                : message,
            actions: loading.value ? [] : actions,
          );
        },
      ),
    );
  }
}