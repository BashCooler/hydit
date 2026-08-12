import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/utils/utils.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/gallery/bindings.dart';
import 'package:hydit/features/gallery/page/gallery_page.dart';
import 'package:hydit/features/viewer/bindings.dart';
import 'package:hydit/features/viewer/page/viewer.dart';
import 'package:hydit/widgets/common/images.dart';

import '../getx/base.dart';
import '../getx/batch.dart';
import '../getx/single.dart';


class PreviewGrid extends StatelessWidget {
  final String tag;

  const PreviewGrid({super.key, required this.tag});

  static const placeholder = ColoredBox(color: Colors.black12);

  TagManager get manager => Get.find(tag: tag);

  Widget count(int count) {
    return ColoredBox(
      color: Colors.black12,
      child: Center(
        child: '+$count'.n..labelLarge,
      ),
    );
  }

  void previewGallery() {
    final manager = this.manager as BatchTagManager;

    final ids = manager.files
        .map((file) => file.id)
        .toList();

    final tag = 'Gallery'.unique();

    Get.to(
      () => Gallery(
        tag: tag,
        editor: false,
        swipeGesture: true,
      ),
      curve: Curves.easeInOutCubic,
      opaque: false,
      binding: GalleryBindings(
        tag: tag,
        ids: ids,
        search: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final files = manager.take(4);
    final length = files.length;

    if (length == 1) {

      return Obx(() {
        final manager = this.manager as PagedTagManager;

        final file = manager.file;

        return GestureDetector(
          onTap: () => openPreview(file),
          child: LinearHero(
            tag: 'Preview ${file.id}',
            child: Thumbnail(file.thumbnailUrl),
          ),
        );
      });
    }

    return GestureDetector(
      onTap: previewGallery,
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
    final files = FileStore([file.id]);

    final tag = 'Viewer'.unique();

    Get.to(
      () => Viewer(tag: tag, editor: false),
      transition: .fadeIn,
      curve: Curves.easeInCubic,
      opaque: false,
      binding: ViewerBindings(
        tag: tag,
        files: files,
        index: 0,
      ),
      arguments: {
        'heroPrefix': 'Preview ',
      }
    );
  }
}
