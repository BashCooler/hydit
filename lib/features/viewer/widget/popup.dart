import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/reactive/file.dart';
import 'package:hydit/services/snack.dart';
import 'package:hydit/services/executor/executor.dart';
import 'package:hydit/widgets/systems/acrylic.dart' as a;


class ViewerPopup extends StatelessWidget {
  final HydrusFile file;

  const ViewerPopup({super.key, required this.file});

  void download() => file.download()
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
    ]);
  }
}
