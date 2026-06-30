import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hydit/features/editor/widget/dropdown.dart';
import 'package:hydit/services/executor.dart';
import 'package:hydit/services/snack.dart';
import 'package:hydit/utils/utils.dart';
import 'package:hydit/widgets/dialog.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/reactive/file.dart';
import 'package:hydit/widgets/images.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/viewer/getx/page.dart';
import 'package:hydit/features/viewer/page/preview.dart';
import 'package:hydit/features/gallery/bindings.dart';

import '../getx/manager.dart';
import '../widget/widgets.dart';

enum Action { save, discard, cancel }
enum Mode { paged, batch }


class Editor extends StatelessWidget {
  final String tag;
  final Mode mode;

  const Editor({super.key, required this.tag, required this.mode});

  TagManager get manager => Get.find();
  FileStore get files => Get.find(tag: tag);
  PageGetxController get page => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onLeave,
      child: Scaffold(
        appBar: EditorAppBar(
          tag: tag,
          mode: mode,
          onTap: () => switch (mode) {
            .paged => openPreview(page.i, files[page.i]),
            .batch => GalleryPage()
                .predictive()
                .withFiles(files)
                .push(),
          },
          child: buildPreview(),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const Expanded(
                child: Up(),
              ),
              const Divider(height: 1),
              SizedBox(
                height: 55 * 3,
                child: Down(tag: tag),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: .endFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: Navigator.of(context).maybePop,
          child: const Icon(Icons.check),
        ),
        bottomNavigationBar: SafeArea(
          child: Column(
            mainAxisSize: .min,
            children: [
              const Divider(height: 1),
              EditorBottomBar(
                tag: tag,
                mode: mode,
                callback: confirmPendingChanges,
              ),
              const ServiceDropdown(),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: BUILDERS

  Widget buildPreview() {
    if (mode == .batch) {
      return PreviewGrid(manager: manager);
    }

    return Obx(() {
      final file = files[page.i];
      return LinearHero(
        tag: 'Preview ${file.id}',
        child: Thumbnail(file.thumbnailUrl),
      );
    });
  }

  // MARK: NAV

  void openPreview(int index, HydrusFile file) {
    final tag = 'Preview-${DateTime.now().microsecondsSinceEpoch}';
    Get.to(() => Preview(tag: tag, index: index, file: file),
      transition: .fadeIn,
      curve: Curves.easeInCubic,
      opaque: false,
      binding: BindingsBuilder.put(() =>
          PageGetxController(initial: index), tag: tag),
    );
  }

  Future<void> onLeave(bool didPop, Object? result) async {
    if (didPop) return;
    if (await confirmPendingChanges()) Get.back();
  }

  Future<bool> confirmPendingChanges() async {
    if (manager.unlocked) return true;
    return await showPopDialog() ?? true;
  }

  Future<bool?> showPopDialog() async {
    return Get.dialog(
      barrierDismissible: true,
      transitionDuration: 150.ms,
      LoadingDialog(
        icon: const Icon(Icons.save),
        title: 'Apply changes?'.n,
        loadingTitle: 'Saving...'.n,
        discardButton: true,
        onApply: () {
          return manager
              .save()
              .tapSuccess((_) => Get.back())
              .tapFailure(Snack.error);
        },
      ),
    );
  }
}
