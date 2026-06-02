import 'package:flutter/material.dart';


/// We have to use this workaround to make sure the text selection
/// and other gestures work as intended when [SettingsPage] pushed
/// via [BackSwipePageRoute]
class FakeScrollableWrapper extends StatelessWidget {
  final Widget child;

  const FakeScrollableWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: MediaQuery.of(context).size.width,
      child: PageView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          child,
        ],
      ),
    );
  }
}
