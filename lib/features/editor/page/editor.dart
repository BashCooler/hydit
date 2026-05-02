import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:hydrus_flutter/utils/theme.dart';
import 'package:hydrus_flutter/core/domain/di/images.dart';
import 'package:hydrus_flutter/features/viewer/getx/page.dart';
import 'package:hydrus_flutter/features/gallery/getx/query.dart';

import '../getx/tags.dart';
import '../widget/app_bar.dart';
import '../widget/search_bar.dart';
import '../widget/tab_builder.dart';


const additions = Color(0xFF3fb950);
const deletions = Color(0xFFf85149);


enum Action {
  save,
  discard,
  cancel
}


class Editor extends StatefulWidget {
  const Editor({super.key});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  final scrollUp = ScrollController();

  final Images images = Get.find();
  late final TagManager manager;
  final PageGetxController page = Get.find();

  @override
  void initState() {
    super.initState();
    manager = Get.put(TagManager()..init(images[page.i].service));
  }

  @override
  void dispose() {
    scrollUp.dispose();
    super.dispose();
  }

  void safePop() {
    if (context.mounted) Navigator.of(context).pop();
  }

  void clearQuery() =>
      Future.delayed(AppTheme.duration, Get.find<QueryController>().clear);

  // MARK: BUILD

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onLeave,
      child: Scaffold(
        appBar: const EditorAppBar(toolbarHeight: 100),
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
                    onPressed: () {},
                  ),
                  const Expanded(child: EditorTagSearchBar()),
                  IconButton(
                    tooltip: 'Next page',
                    icon: const Icon(Icons.keyboard_arrow_right),
                    onPressed: () {},
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
    final message = manager.summarize();
    if (message == 'No changes') {
      Navigator.of(context).pop();
    } else {
      final result = await showPopDialog(context, message);

      switch (result) {
        case .save:
          clearQuery();
          safePop();
        case .discard:
          clearQuery();
          safePop();
        case _:
          break;
      }
    }
  }

  // MARK: DIALOG

  Future<Action?> showPopDialog(BuildContext context, String message) {
    bool isLoading = false;

    return showDialog<Action>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              actionsAlignment: .center,
              icon: const Icon(Icons.save),
              title: isLoading
                  ? const Text('Saving...')
                  : const Text('Save changes?'),
              content: isLoading
                  ? const LinearProgressIndicator()
                  : Text(message),
              actions: isLoading ? <Widget>[] : <Widget>[
                TextButton(
                  onPressed: () async {
                    setState(() => isLoading = true);
                    await manager.save(images[page.i]);
                    if (context.mounted) Navigator.of(context).pop(Action.save);
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
              ],
            );
          },
        );
      },
    );
  }
}
