import 'package:get/get.dart';
import 'package:flutter/material.dart' hide Action;

import 'package:hydit/widgets/dialog.dart';
import 'package:hydit/services/snack.dart';
import '../getx/tags.dart';


class EditorDialog extends StatelessWidget {
  final ValueNotifier<bool> loading;
  final Widget message;

  const EditorDialog({
    super.key,
    required this.loading,
    required this.message,
  });

  TagManager get manager => Get.find();

  Future<void> save() async {
    loading.value = true;

    final success = await manager.save();
    if (success) Get.back(result: true);

    Snack.error('Save error', 'Failed to save changes');
    loading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return ConfirmDialog(
      icon: const Icon(Icons.save),
      loading: loading,
      message: message,
      title: const Text('Save changes?'),
      loadingTitle: const Text('Saving...'),
      actions: [
        TextButton(
          onPressed: save,
          child: const Text('Save'),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: const Text('Discard'),
        ),
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
