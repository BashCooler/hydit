import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/utils/utils.dart';
import 'package:hydit/entities/tag.dart';
import 'package:material_symbols_icons/symbols.dart';


Future<void> showToggleDialog(Tag tag, {
  required void Function() onAdd,
  required void Function() onDel,
}) {
  return Get.dialog(
    transitionDuration: 150.ms,
    AlertDialog(
      icon: const Icon(Symbols.arrow_split),
      actionsAlignment: .center,
      title: const Text('Add or delete tag?'),
      actions: [
        TextButton(
          onPressed: onAdd,
          child: const Text('Add'),
        ),
        TextButton(
          onPressed: onDel,
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
