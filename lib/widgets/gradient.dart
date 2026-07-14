import 'package:flutter/material.dart' hide IconButton;
import 'package:flutter/material.dart' as m;


const onGradientShadow = [
  Shadow(blurRadius: 16),
];


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
      automaticallyImplyLeading: automaticallyImplyLeading,
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


class OnGradientIconButton extends StatelessWidget {
  final IconData? icon;
  final String? tooltip;
  final void Function()? onPressed;

  const OnGradientIconButton(this.icon, {
    super.key,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: m.IconButton(
        tooltip: tooltip,
        icon: Icon(
          icon,
          color: Colors.white,
          shadows: const [
            Shadow(blurRadius: 16),
          ],
        ),
        onPressed: onPressed,
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
