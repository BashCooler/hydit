import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/reactive/file.dart';
import 'package:hydit/widgets/images.dart';
import 'package:hydit/reactive/file_store.dart';
import 'package:hydit/features/viewer/getx/page.dart';
import 'package:hydit/features/viewer/page/preview.dart';
import 'package:hydit/features/gallery/bindings.dart';

import '../getx/tags.dart';
import '../widget/widgets.dart';


const additions = Color(0xFF3fb950);
const deletions = Color(0xFFf85149);

enum Action { save, discard, cancel }
enum Mode { paged, batch }


class Editor extends StatefulWidget {
  final String tag;
  final Mode mode;

  const Editor({super.key, required this.tag, required this.mode});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {

  TagManager get manager => Get.find();
  FileStore get files => Get.find(tag: widget.tag);
  PageGetxController get page => Get.find(tag: widget.tag);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onLeave,
      child: Scaffold(
        appBar: EditorAppBar(
          tag: widget.tag,
          mode: widget.mode,
          onTap: () => switch (widget.mode) {
                .paged => openPreview(page.i, files[page.i]),
                .batch => GalleryPage()
                .withSwipeBackGesture()
                .withFiles(files)
                .push(),
          },
          child: buildPreview(),
        ),
        body: n.Column([
          TabBuilder(tag: widget.tag),
          const Divider(height: 1),
          EditorBottomBar(
            tag: widget.tag,
            mode: widget.mode,
            callback: confirmPendingChanges,
          ),
        ])
          ..safe,
        floatingActionButtonLocation: .miniEndFloat,
        floatingActionButton: Padding(
          padding: const .only(bottom: 60),
          child: FloatingActionButton(
            onPressed: Navigator.of(context).maybePop,
            child: const Icon(Icons.check),
          ),
        ),
      ),
    );
  }

  // MARK: BUILDERS

  Widget buildPreview() {
    switch (widget.mode) {
      case .paged:
        return Obx(() {
          return HeroMode(
            enabled: page.enabled(page.i),
            child: LinearHero(
              tag: files[page.i].id,
              child: Thumbnail(files[page.i]),
            ),
          );
        });
      case .batch:
        return PreviewGrid(manager: manager);
    }
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
    final shouldLeave = await confirmPendingChanges();
    if (shouldLeave && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<bool> confirmPendingChanges() async {
    final message = manager.summarize();
    if (message == null) return true;
    return await showPopDialog(message) ?? true;
  }

  Future<bool?> showPopDialog(String message) {
    final loading = ValueNotifier<bool>(false);

    return showDialog<bool>(
      context: context,
      barrierDismissible: !loading.value,
      builder: (context) {
        return EditorDialog(
          loading: loading,
          message: Text(message),
        );
      },
    );
  }
}
