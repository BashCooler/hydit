import 'package:flutter/material.dart';

import 'package:hydit/utils/theme.dart';
import 'package:hydit/entities/service.dart';


class const ServiceList(
  final Map<String, TagService> tags, {
  super.key,
  final ScrollController? controller,
  final bool shrinkWrap = false,
  final void Function(String name)? onTap,
}) extends StatelessWidget {
  //
  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListView(
        padding: Insets.listPadding,
        controller: controller,
        shrinkWrap: shrinkWrap,
        children: [
          for (final MapEntry(key: name, value: tags) in tags.entries)
            if (name != 'all known tags')
              Card(
                clipBehavior: .hardEdge,
                child: ListTile(
                  onTap: () => onTap?.call(name),
                  title: Text(name),
                  trailing: Row(
                    spacing: 5,
                    mainAxisSize: .min,
                    children: [
                      ?tags.display.isNotEmpty
                          ? Badge(label: Text('${tags.storage.length}'))
                          : null,
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
