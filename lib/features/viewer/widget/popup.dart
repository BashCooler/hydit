import 'package:flutter/material.dart';
import 'package:hydit/reactive/file.dart';
import 'package:niku/namespace.dart' as n;


class ViewerPopup extends StatelessWidget {
  final HydrusFile file;

  const ViewerPopup({super.key, required this.file});

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

          PopupMenuItem<String>(
            onTap: () {},
            child: 'copy'.n,
          ),

          PopupMenuItem<String>(
            onTap: file.download,
            child: 'download'.n,
          ),

        ];
      },
    );
  }
}
