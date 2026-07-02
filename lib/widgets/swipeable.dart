import 'package:flutter/material.dart';
import 'package:full_swipe_back_gesture/full_swipe_back_gesture.dart' as s;


class SwipeablePage extends StatelessWidget {
  final Widget child;

  const SwipeablePage({super.key, required this.child});

  static const decoration = BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Color.fromARGB(128, 0, 0, 0),
        blurRadius: 5,
      )
    ],
  );

  @override
  Widget build(BuildContext context) {
    return s.SwipeablePage(
      child: Container(
        decoration: decoration,
        child: child,
      ),
    );
  }
}
