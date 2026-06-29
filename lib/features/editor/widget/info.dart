import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import '../getx/tags.dart';


class Diff extends StatelessWidget {
  const Diff({super.key});

  static const additions = Color(0xFF3fb950);
  static const deletions = Color(0xFFf85149);

  TagManager get manager => Get.find();

  @override
  Widget build(BuildContext context) => Obx(() {
    final add = manager.additions.length;
    final del = manager.deletions.length;

    return Padding(
      padding: const .symmetric(horizontal: 8),
      child: Row(
        spacing: 6,
        children: [
          if (add > 0) '+$add'.n
            ..fontSize = 16
            ..color = additions,

          if (del > 0) '-$del'.n
            ..fontSize = 16
            ..color = deletions,
        ],
      ),
    );
  });
}
