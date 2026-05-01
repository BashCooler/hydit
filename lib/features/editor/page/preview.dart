import 'package:flutter/material.dart';
import 'package:dismissible_page/dismissible_page.dart';

import 'package:hydrus_flutter/features/viewer/widget/views.dart';


class Preview extends StatelessWidget {
  final int index;

  const Preview({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      disabled: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      onDismissed: Navigator.of(context).pop,
      direction: .vertical,
      interactionMode: .gesture,
      minScale: 0,
      builder: (context, scrollController) {
        // TODO make viewer work here
        return IgnorePointer(
          child: ViewFile(index),
        );
      },
    );
  }
}
