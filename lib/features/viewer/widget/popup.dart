import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/services/snack.dart';
import 'package:hydit/services/executor/executor.dart';
import 'package:hydit/widgets/systems/acrylic.dart' as a;

import '../getx/page.dart';


class ViewerPopup extends StatelessWidget {
  final String tag;

  const ViewerPopup({super.key, required this.tag});

  PageGetxController get page => Get.find(tag: tag);

  bool get delete => Get.arguments?['delete'] ?? false;

  void download() => page.current.download()
      .tapFailure(Snack.error)
      .tapSuccess(showSuccess);

  void showSuccess(void value) {
    Snack.success('Success', 'File saved to downloads');
  }

  @override
  Widget build(BuildContext context) {
    return a.More([
      PopupMenuItem(
        onTap: download,
        child: 'download'.n,
      ),

      if (delete)
        PopupMenuItem(
          onTap: page.delete,
          child: 'delete'.n,
        ),
    ]);
  }
}
