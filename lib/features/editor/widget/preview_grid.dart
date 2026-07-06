import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/extra/primitive.dart';

import 'package:hydit/features/editor/getx/base.dart';
import 'package:hydit/features/gallery/bindings.dart';
import 'package:hydit/features/viewer/getx/page.dart';
import 'package:hydit/features/viewer/page/preview.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/reactive/file_store.dart';

import 'package:hydit/widgets/images.dart';


class PreviewGrid extends StatelessWidget {
  final String tag;

  const PreviewGrid({super.key, required this.tag});

  static const placeholder = ColoredBox(color: Colors.black12);

  TagManagerBase get manager => Get.find();
  FileStore get files => Get.find(tag: tag);

  Widget count(int count) {
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
    final length = files.length;

    if (length == 1) {
      final file = files.first;

      return GestureDetector(
        onTap: () => openPreview(file),
        child: LinearHero(
          tag: 'Preview ${file.id}',
          child: Thumbnail(files.first.thumbnailUrl),
        ),
      );
    }

    return GestureDetector(
      onTap: () => GalleryPage()
          .predictive()
          .withFiles(this.files)
          .push(),
      child: GridView.count(
        crossAxisCount: 2,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
        children: [
          Thumbnail(files.first.thumbnailUrl),
          length > 1 ? Thumbnail(files[1].thumbnailUrl) : placeholder,
          length > 2 ? Thumbnail(files[2].thumbnailUrl) : placeholder,
          length > 3 ? count(manager.fileCount - 3) : placeholder,
        ],
      ),
    );
  }

  void openPreview(HydrusFile file) {
    final tag = 'Preview-${DateTime.now().microsecondsSinceEpoch}';
    Get.to(() => Preview(tag: tag, index: 0, file: file),
      transition: .fadeIn,
      curve: Curves.easeInCubic,
      opaque: false,
      binding: BindingsBuilder.put(() =>
          PageGetxController(initial: 0), tag: tag),
    );
  }
}
