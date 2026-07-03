import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;


class ViewerPopup extends StatelessWidget {
  const ViewerPopup({super.key});

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
            onTap: () {},
            child: 'download'.n,
          ),

        ];
      },
    );
  }
}
