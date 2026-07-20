import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/services/executor/executor.dart';


class LoadingDialogBuilder {
  Widget? icon;
  Widget title = const Text('Confirm?');
  Widget loadingTitle = const Text('Loading...');
  Widget? content;
  Widget applyText = const Text('Apply');
  Widget? discardButton;
  Future<Result<void>> Function()? onApply;

  Future<void> show() => Get.dialog(
    barrierDismissible: false,
    transitionDuration: 150.ms,
    LoadingDialog(
      icon: icon,
      title: title,
      loadingTitle: loadingTitle,
      content: content,
      applyText: applyText,
      discardButton: discardButton,
      onApply: onApply!,
    ),
  );
}


class LoadingDialog extends HookWidget {
  final Widget? icon;
  final Widget title;
  final Widget loadingTitle;
  final Widget? content;
  final Widget applyText;
  final Widget? discardButton;
  final Future<Result<void>> Function() onApply;

  const LoadingDialog({
    super.key,
    this.icon,
    this.content,
    required this.title,
    required this.loadingTitle,
    this.applyText = const Text('Apply'),
    this.discardButton,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final loading = useState(false);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (loading.value) return;
        Navigator.of(context).pop(false);
      },
      child: AlertDialog(
        icon: icon,
        actionsAlignment: .center,
        title: loading.value ? loadingTitle : title,
        content: loading.value
            ? const LinearProgressIndicator()
            : content,
        actions: loading.value ? [] : [
          TextButton(
            onPressed: () async => await onApply()
                .loading(loading),
            child: applyText,
          ),
          ?discardButton,
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}


class ProgressDialog extends HookWidget {
  final int progress;
  final int full;
  final Widget? title;
  final CancellationToken token;

  const ProgressDialog({
    super.key,
    required this.progress,
    required this.full,
    this.title,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: .center,
      title: title,
      content: Column(
        mainAxisSize: .min,
        spacing: 15,
        children: [
          LinearProgressIndicator(value: (progress / full).clamp(0, 1)),
          '$progress/$full'.n,
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            token.cancel();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
