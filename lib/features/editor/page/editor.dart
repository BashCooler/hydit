import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/core/ui/images.dart';
import 'package:hydit/core/domain/entities.dart';
import 'package:hydit/core/domain/file_repo.dart';
import 'package:hydit/features/viewer/getx/page.dart';
import 'package:hydit/features/viewer/page/preview.dart';
import 'package:hydit/features/gallery/getx/bindings.dart';

import '../getx/tags.dart';
import '../widget/app_bar.dart';
import '../widget/bottom_bar.dart';
import '../widget/tab_builder.dart';
import '../widget/preview_grid.dart';

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
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onLeave,
      child: Scaffold(
        appBar: buildAppBar(),
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
        floatingActionButton: buildActionButton(),
      ),
    );
  }

  // MARK: BUILDERS

  PreferredSizeWidget buildAppBar() {
    switch (widget.mode) {
      case .paged:
        final FileRepo files = Get.find(tag: widget.tag);
        final PageGetxController page = Get.find(tag: widget.tag);
        return EditorAppBar(
          toolbarHeight: 100,
          tag: widget.tag,
          onTap: () => openPreview(page.i, files[page.i]),
          mode: .paged,
          child: Obx(() {
            return HeroMode(
              enabled: page.enabled(page.i),
              child: LinearHero(
                tag: files[page.i].id,
                child: Thumbnail(files[page.i]),
              ),
            );
          }),
        );
      case .batch:
        final TagManager manager = Get.find();
        return EditorAppBar(
          toolbarHeight: 100,
          mode: .batch,
          tag: widget.tag,
          child: PreviewGrid(
            manager: manager,
            onTap: () {
              final FileRepo fileRepo = Get.find(tag: widget.tag);
              toGallery(mode: .preview, files: fileRepo);
            },
          ),
        );
    }
  }

  Widget buildActionButton() {
    return Padding(
      padding: const .only(bottom: 60),
      child: FloatingActionButton(
        onPressed: Navigator.of(context).maybePop,
        child: const Icon(Icons.check),
      ),
    );
  }

  // MARK: NAV

  void openPreview(int index, HydrusFile file) {
    final tag = 'Preview-${DateTime.now().microsecondsSinceEpoch}';
    Get.to(() => Preview(tag: tag, index: index, file: file),
      transition: .fadeIn,
      curve: Curves.easeInCubic,
      opaque: false,
      binding: BindingsBuilder.put(() => PageGetxController(initial: index), tag: tag),
    );
  }

  Future<void> onLeave(bool didPop, Object? result) async {
    if (didPop) return;
    final shouldLeave = await confirmPendingChanges(widget.tag);
    if (shouldLeave && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<bool> confirmPendingChanges(String tag) async {
    final TagManager manager = Get.find();

    final message = manager.summarize();
    if (message == 'No changes') return true;

    final result = await showPopDialog(context, message, tag);

    switch (result) {
      case .save:
        return true;
      case .discard:
        return true;
      case _:
        return false;
    }
  }

  // MARK: DIALOG

  Future<Action?> showPopDialog(BuildContext context, String message,
      String tag) {
    bool isLoading = false;
    final TagManager manager = Get.find();

    return showDialog<Action>(
      context: context,
      barrierDismissible: !isLoading,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final nav = Navigator.of(context);
            final actions = <Widget>[
              n.Button('Save'.n)
                ..onPressed = () async {
                  setState(() => isLoading = true);
                  await manager.save();
                  if (context.mounted) nav.pop(Action.save);
                },
              n.Button('Discard'.n)
                ..onPressed = () => nav.pop(Action.discard),
              n.Button('Cancel'.n)
                ..onPressed = () => nav.pop(Action.cancel),
            ];

            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                if (isLoading) return;
                Get.back();
              },
              child: AlertDialog(
                actionsAlignment: .center,
                icon: const Icon(Icons.save),
                title: isLoading
                    ? const Text('Saving...')
                    : const Text('Save changes?'),
                content: isLoading
                    ? const LinearProgressIndicator()
                    : Text(message),
                actions: isLoading ? <Widget>[] : actions,
              ),
            );
          },
        );
      },
    );
  }
}
