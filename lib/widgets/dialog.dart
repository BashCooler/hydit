import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hydit/services/executor.dart';


class LoadingDialog extends HookWidget {
  final Widget? icon;
  final Widget title;
  final Widget loadingTitle;
  final Widget? content;
  final bool discardButton;
  final Future<Result<void>> Function() onApply;

  const LoadingDialog({
    super.key,
    this.icon,
    this.content,
    required this.title,
    required this.loadingTitle,
    this.discardButton = false,
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
      child: ValueListenableBuilder(
        valueListenable: loading,
        builder: (context, value, child) {
          return AlertDialog(
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
                child: const Text('Save'),
              ),
              if (discardButton) TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Discard'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      ),
    );
  }
}