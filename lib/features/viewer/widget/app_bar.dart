import 'package:flutter/material.dart';

import 'package:hydit/widgets/systems/gradient.dart';


class const ViewerAppBar({
  super.key,
  final bool visible = true,
}) extends StatelessWidget {
  //
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: visible ? 1 : 0,
      child: GradientAppBar(
        enabled: false,
        automaticallyImplyLeading: false,
      ),
    );
  }
}
