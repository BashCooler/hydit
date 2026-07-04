import 'package:flutter/material.dart';
import 'package:hydit/reactive/file.dart';
import 'package:hydit/services/executor.dart';
import 'package:hydit/services/snack.dart';
import 'package:niku/namespace.dart' as n;


class ViewerPopup extends StatelessWidget {
  final HydrusFile file;

  const ViewerPopup({super.key, required this.file});

  void showSuccess(void value) {
    Snack.success('Success', 'File saved to downloads');
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context)
            .colorScheme
            .onPrimaryContainer,
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            onTap: () => file
                .download()
                .tapFailure(Snack.error)
                .tapSuccess(showSuccess),
            child: 'download'.n,
          ),
        ];
      },
    );
  }
}
