import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/utils/utils.dart';
import 'package:hydit/widgets/common/dialog.dart';
import 'package:hydit/services/services.dart';

import '../getx/base.dart';
import '../widget/widgets.dart';
import '../widget/dropdown.dart';


enum Action { save, discard, cancel }


class Editor extends StatelessWidget {
  final String tag;

  const Editor({super.key, required this.tag});

  TagManager get manager => Get.find(tag: tag);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onLeave,
      child: Scaffold(
        appBar: EditorAppBar(tag: tag),
        body: SafeArea(
          child: Obx(() {

            return Column(
              children: [
                Up(tag: tag, tags: manager.tags),

                if (manager.editable)
                  const Divider(height: 1),

                if (manager.editable)
                  SizedBox(
                    height: 55 * 3,
                    child: Down(tag: tag),
                  ),

                const Divider(height: 1),
                EditorTagSearchBar(tag: tag),
              ],
            );
          }),
        ),
        floatingActionButtonLocation: .endFloat,
        bottomNavigationBar: SafeArea(
          child: EditorBottomBar(
            tag: tag,
            callback: confirmPendingChanges,
            child: ServiceDropdown(tag: tag),
          ),
        ),
      ),
    );
  }

  // MARK: NAV

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
        discard: TextButton(
          onPressed: () => Get.back(result: true),
          child: const Text('Discard'),
        ),
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
