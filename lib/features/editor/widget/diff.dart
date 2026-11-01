import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import '../getx/base.dart';


class Diff extends StatelessWidget {
  final String tag;
  final String service;

  const Diff({super.key, required this.tag, required this.service});

  static const additions = Color(0xFF3fb950);
  static const deletions = Color(0xFFf85149);

  TagManager get manager => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) => Obx(() {
    final (add, del) = manager.diff(service);

    return Container(
      padding: const .symmetric(horizontal: 8),
      child: Row(
        spacing: 6,
        children: [
          if (add > 0) '+$add'.n
            ..fontSize = 16
            ..color = additions
            ..fontFamily = 'monospace',

          if (del > 0) '-$del'.n
            ..fontSize = 16
            ..color = deletions
            ..fontFamily = 'monospace',
        ],
      ),
    );
  });
}
