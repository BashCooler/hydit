import 'package:flutter/material.dart';


class SideBar extends StatelessWidget {
  final List<Widget> tiles;

  const SideBar({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Align(
        alignment: .center,
        child: ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: tiles.length,
          itemBuilder: (context, index) => tiles[index],
          separatorBuilder: (_, _) => const Divider(),
        ),
      ),
    );
  }
}
