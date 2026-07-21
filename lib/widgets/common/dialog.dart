import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hydit/utils/utils.dart';
import 'package:hydit/services/executor/executor.dart';


class LoadingDialog extends HookWidget {
  final Widget? icon;
  final Widget title;
  final Widget loadingTitle;
  final Widget? content;
  final Widget applyText;
  final Widget? discardButton;
  final Future<Result<void>> Function() onApply;
  final CompletionToken? token;

  const LoadingDialog._({
    this.icon,
    this.content,
    required this.title,
    required this.loadingTitle,
    this.applyText = const Text('Confirm'),
    this.discardButton,
    required this.onApply,
    this.token,
  });

  /// Show a loading dialog.
  ///
  /// If the operation completed successfully, the [token]
  /// will be marked completed.
  static Future<void> show({
    Widget? icon,
    Widget title = const Text('Confirm?'),
    Widget loadingTitle = const Text('Loading...'),
    Widget? content,
    Widget applyText = const Text('Confirm'),
    Widget? discardButton,
    required Future<Result<void>> Function() onApply,
    CompletionToken? token,
  }) {
    return Get.dialog(
      barrierDismissible: false,
      transitionDuration: 150.ms,
      LoadingDialog._(
        icon: icon,
        content: content,
        title: title,
        loadingTitle: loadingTitle,
        applyText: applyText,
        discardButton: discardButton,
        onApply: onApply,
        token: token,
      ),
    );
  }

  void onSuccess(void data) {
    token?.complete();
    Get.back();
  }

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
            onPressed: () => onApply()
                .loading(loading)
                .tapSuccess(onSuccess),
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
