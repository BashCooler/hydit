import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import '../getx/base.dart';


class Diff extends StatelessWidget {
  final String? service;

  const Diff({super.key, this.service});

  static const additions = Color(0xFF3fb950);
  static const deletions = Color(0xFFf85149);

  TagManagerBase get manager => Get.find();

  @override
  Widget build(BuildContext context) => Obx(() {
    final diff = manager.diff(service);

    return Container(
      padding: const .symmetric(horizontal: 8),
      child: Row(
        spacing: 6,
        children: [
          if (diff.add > 0) '+${diff.add}'.n
            ..fontSize = 16
            ..color = additions
            ..fontFamily = 'monospace',

          if (diff.del > 0) '-${diff.del}'.n
            ..fontSize = 16
            ..color = deletions
            ..fontFamily = 'monospace',
        ],
      ),
    );
  });
}
