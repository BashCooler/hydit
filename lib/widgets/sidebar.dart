import 'package:flutter/material.dart';
import 'package:hydit/features/settings/bindings.dart';


class AppSideBar extends StatelessWidget {
  const AppSideBar({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      ListTile(
        leading: Icon(Icons.settings),
        title: Text('Settings'),
        onTap: SettingsPage().push,
      ),
    ];

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
