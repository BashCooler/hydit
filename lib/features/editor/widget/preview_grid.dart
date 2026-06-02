import 'package:flutter/material.dart';
import 'package:niku/extra/primitive.dart';

import 'package:hydit/widgets/images.dart';
import 'package:hydit/features/editor/getx/tags.dart';


class PreviewGrid extends StatelessWidget {
  final TagManager manager;
  final GestureTapCallback? onTap;

  const PreviewGrid({super.key, required this.manager, this.onTap});

  static const placeholder = ColoredBox(color: Colors.black12);

  Widget buildCount(int count) {
    return ColoredBox(
      color: Colors.black12,
      child: Center(
        child: '+$count'.n..labelLarge,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final files = manager.take(4);
    final count = buildCount(manager.fileCount - 3);

    return GestureDetector(
      onTap: onTap,
      child: GridView.count(
        crossAxisCount: 2,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
        children: [
          files.isNotEmpty ? Thumbnail(files[0]) : placeholder,
          files.length > 1 ? Thumbnail(files[1]) : placeholder,
          files.length > 2 ? Thumbnail(files[2]) : placeholder,
          files.length > 3 ? count : placeholder,
        ],
      ),
    );
  }
}
