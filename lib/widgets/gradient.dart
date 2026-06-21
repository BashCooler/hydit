import 'package:flutter/material.dart';


class GradientAppBar extends StatelessWidget
    implements PreferredSizeWidget {

  final bool automaticallyImplyLeading;
  final Widget? title;
  final List<Widget>? actions;

  const GradientAppBar({
    super.key,
    this.automaticallyImplyLeading = true,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpace(),
      title: title,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


class GradientBottomAppBar extends StatelessWidget {
  final Widget? child;

  const GradientBottomAppBar({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Theme.of(context)
                .scaffoldBackgroundColor
                .withAlpha(128),
          ],
          begin: .topCenter,
          end: .bottomCenter,
        ),
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        child: Padding(
          padding: const .symmetric(horizontal: 10),
          child: child,
        ),
      ),
    );
  }
}



class FlexibleSpace extends StatelessWidget {
  const FlexibleSpace({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context)
                .scaffoldBackgroundColor
                .withAlpha(128),
            Colors.transparent,
          ],
          begin: .topCenter,
          end: .bottomCenter,
        ),
      ),
    );
  }
}
