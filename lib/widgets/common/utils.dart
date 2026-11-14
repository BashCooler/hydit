import 'package:flutter/material.dart';


class const EmptyAppBar({
  super.key,
  @override final Size preferredSize = const Size.fromHeight(kToolbarHeight),
  required final Widget child,
}) extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) => child;
}
