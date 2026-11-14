import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/utils/theme.dart';
import 'package:hydit/services/services.dart';
import 'package:hydit/widgets/common/dialog.dart';
import 'package:hydit/widgets/common/swipeable.dart';
import 'package:hydit/features/editor/bindings.dart';

import '../getx/base.dart';
import '../widget/widgets.dart';


class Editor extends StatelessWidget {
  final EditorBindings bindings;

  const Editor({super.key, required this.bindings});

  String get tag => bindings.tag;

  TagManager get manager => bindings.manager;

  @override
  Widget build(BuildContext context) {
    return SwipeablePage(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: onLeave,
        child: Scaffold(
          appBar: EditorAppBar(tag: tag),
          body: SafeArea(
            child: Obx(() {

              return TextFieldTapRegion(
                child: Column(
                  children: [
                    EditorTagList(tag: tag, tags: manager.tags),

                    if (manager.editable)
                      const Divider(height: 1),

                    if (manager.editable)
                      SizedBox(
                        height: Sizes.smallList,
                        child: EditorSuggests(tag: tag),
                      ),

                    const Divider(height: 1),

                    EditorTagSearchBar(tag: tag),
                  ],
                ),
              );
            }),
          ),
          floatingActionButtonLocation: .endFloat,
          bottomNavigationBar: SafeArea(
            maintainBottomViewPadding: true,
            child: EditorBottomBar(
              tag: tag,
              callback: confirmPendingChanges,
              child: ServiceDropdown(tag: tag),
            ),
          ),
        ),
      ),
    );
  }

  // MARK: NAV

  Future<void> onLeave(bool didPop, Object? result) async {
    if (!didPop && await confirmPendingChanges()) {
      Get.back();
    }
  }

  Future<bool> confirmPendingChanges() async {
    if (manager.unlocked) return true;

    final token = CompletionToken();

    await LoadingDialog.show(
      token: token,
      icon: const Icon(Icons.save),
      title: 'Apply changes?'.n,
      loadingTitle: 'Saving...'.n,
      discardButton: TextButton(
        onPressed: () {
          token.complete();
          Get.back();
        },
        child: const Text('Discard'),
      ),
      onApply: () => manager
          .save()
          .tapFailure(Snack.error),
    );

    return token.completed;
  }
}
