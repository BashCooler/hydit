import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydrus_flutter/core/domain/di/images.dart';
import 'package:hydrus_flutter/features/viewer/getx/page.dart';

import '../getx/tags.dart';
import '../widget/app_bar.dart';
import '../widget/search_bar.dart';
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
  final scrollUp = ScrollController();

  final Images images = Get.find();
  late final TagManager manager;
  late final PageGetxController page;

  @override
  void initState() {
    super.initState();
    page = Get.find(tag: widget.tag);
    manager = Get.put(TagManager()..init(images[page.i].service));
  }

  @override
  void dispose() {
    scrollUp.dispose();
    super.dispose();
  }

  Future<void> navigateToPage(int target) async {
    if (target < 0) return;
    if (target >= images.length) return;

    final shouldSwitch = await confirmPendingChanges();
    if (!shouldSwitch || !mounted) return;

    page.navigateToPage(target);
    manager.init(images[page.i].service);
  }

  // MARK: BUILD

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onLeave,
      child: Scaffold(
        appBar: EditorAppBar(
          toolbarHeight: 100,
          tag: widget.tag,
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              const TabBuilder(),
              const Divider(height: 1),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Previous page',
                    icon: const Icon(Icons.keyboard_arrow_left),
                    onPressed: () => navigateToPage(page.i - 1),
                  ),
                  const Expanded(child: EditorTagSearchBar()),
                  IconButton(
                    tooltip: 'Next page',
                    icon: const Icon(Icons.keyboard_arrow_right),
                    onPressed: () => navigateToPage(page.i + 1),
                  ),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const .only(bottom: 60),
          child: FloatingActionButton(
            onPressed: Navigator.of(context).maybePop,
            child: const Icon(Icons.check),
          ),
        ),
        floatingActionButtonLocation: .miniEndFloat,
      ),
    );
  }

  // MARK: LEAVE

  Future<void> onLeave(bool didPop, Object? result) async {
    if (didPop) return;
    final shouldLeave = await confirmPendingChanges();
    if (shouldLeave && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<bool> confirmPendingChanges() async {
    final message = manager.summarize();
    if (message == 'No changes') return true;

    final result = await showPopDialog(context, message, page.i);

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

  Future<Action?> showPopDialog(BuildContext context, String message, int index) {
    bool isLoading = false;

    return showDialog<Action>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {

            final actions = <Widget>[
              TextButton(
                onPressed: () async {
                  setState(() => isLoading = true);
                  await manager.save(images[index]);
                  if (context.mounted) {
                    Navigator.of(context).pop(Action.save);
                  }
                },
                child: const Text('Save'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(Action.discard),
                child: const Text('Discard'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(Action.cancel),
                child: const Text('Cancel'),
              ),
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
