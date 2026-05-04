import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydrus_flutter/core/domain/di/images.dart';
import 'package:hydrus_flutter/features/viewer/getx/page.dart';

import '../getx/tags.dart';
import '../widget/app_bar.dart';
import '../widget/bottom_bar.dart';
import '../widget/tab_builder.dart';

const additions = Color(0xFF3fb950);
const deletions = Color(0xFFf85149);

enum Action { save, discard, cancel }


class Editor extends StatefulWidget {
  final String tag;

  const Editor({super.key, required this.tag});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  // MARK: BUILD

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onLeave,
      child: Scaffold(
        appBar: PagedEditorAppBar(
          toolbarHeight: 100,
          tag: widget.tag,
        ),
        body: n.Column([
          TabBuilder(tag: widget.tag),
          const Divider(height: 1),
          PagedEditorBottomBar(
            tag: widget.tag,
            callback: confirmPendingChanges,
          ),
        ])
          ..safe,
        floatingActionButtonLocation: .miniEndFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: Navigator.of(context).maybePop,
          child: const Icon(Icons.check),
        ).niku.paddingOnly(bottom: 60),
      ),
    );
  }

  // MARK: LEAVE

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

    final page = Get.find<PageGetxController>(tag: widget.tag);
    final result = await showPopDialog(context, message, page.i, tag);

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

  Future<Action?> showPopDialog(
    BuildContext context,
    String message,
    int index,
    String tag,
  ) {
    bool isLoading = false;
    final Images images = Get.find();
    final TagManager manager = Get.find();

    return showDialog<Action>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final nav = Navigator.of(context);
            final actions = <Widget>[
              n.Button('Save'.n)
                ..onPressed = () async {
                  setState(() => isLoading = true);
                  await manager.save(images[index]);
                  if (context.mounted) nav.pop(Action.save);
                },
              n.Button('Discard'.n)
                ..onPressed = () => nav.pop(Action.discard),
              n.Button('Cancel'.n)
                ..onPressed = () => nav.pop(Action.cancel),
            ];

            return AlertDialog(
              actionsAlignment: .center,
              icon: const Icon(Icons.save),
              title: isLoading
                  ? const Text('Saving...')
                  : const Text('Save changes?'),
              content: isLoading
                  ? const LinearProgressIndicator()
                  : Text(message),
              actions: isLoading ? <Widget>[] : actions,
            );
          },
        );
      },
    );
  }
}
