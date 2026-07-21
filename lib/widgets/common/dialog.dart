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
  Widget applyText = const Text('Confirm');
  Widget? discardButton;
  Future<Result<void>> Function()? onApply;
  CompletionToken? token;

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
      token: token ?? CompletionToken(),
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
  final CompletionToken token;

  const LoadingDialog({
    super.key,
    this.icon,
    this.content,
    required this.title,
    required this.loadingTitle,
    this.applyText = const Text('Confirm'),
    this.discardButton,
    required this.onApply,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final loading = useState(false);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || loading.value) {
          return;
        }
        Get.back();
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
            onPressed: () async {
              final result = await onApply().loading(loading);

              if (result is Success) {
                token.complete();
                Get.back();
              }
            },
            child: applyText,
          ),
          ?discardButton,
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}


class ProgressDialog extends HookWidget {
  final Widget? title;
  final CancellationToken token;
  final int full;
  final int Function() progress;

  const ProgressDialog._({
    this.title,
    required this.token,
    required this.full,
    required this.progress,
  });

  static Future<void> show({
    Widget? title,
    required CancellationToken token,
    required int full,
    required int Function() progress,
  }) {
    return Get.dialog(
      transitionDuration: 150.ms,
      barrierDismissible: false,
      ProgressDialog._(
        title: title,
        token: token,
        full: full,
        progress: progress,
      ),
    );
  }

  double get value => (progress() / full).clamp(0, 1);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: .center,
      title: title,
      content: Column(
        mainAxisSize: .min,
        spacing: 15,
        children: [
          Obx(() => LinearProgressIndicator(value: value)),
          Obx(() => '${progress()}/$full'.n),
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
