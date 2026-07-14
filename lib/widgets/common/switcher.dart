import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_animate/flutter_animate.dart';


class SequencedSwitcher extends HookWidget {
  final bool visible;
  final bool showFirst;
  final Widget first;
  final Widget second;
  final Duration duration;

  const SequencedSwitcher({
    super.key,
    required this.visible,
    required this.showFirst,
    required this.first,
    required this.second,
    this.duration = const Duration(milliseconds: 150),
  });

  Duration get d1 => duration;

  Widget get current => showFirst ? second : first;
  Widget get target => showFirst ? first : second;

  @override
  Widget build(BuildContext context) {
    final initialized = useRef(false);

    final current = initialized.value
        ? this.current
        : const SizedBox.shrink();

    initialized.value = true;

    return AnimatedScale(
      duration: d1,
      scale: visible ? 1 : 0,
      child: current
          .animate(key: ValueKey('$showFirst'))
          .scaleXY(begin: 1, end: 0, duration: d1)
          .swap(builder: (_, _) => target.animate().scaleXY(duration: d1)),
    );
  }
}
