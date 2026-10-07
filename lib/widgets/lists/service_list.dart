import 'package:flutter/material.dart';
import 'package:hydit/entities/service.dart';
import 'package:hydit/utils/theme.dart';


class ServiceList extends StatelessWidget {
  final Map<String, TagService> tags;
  final ScrollController? controller;
  final bool shrinkWrap;
  final void Function(String name)? onTap;

  
  const ServiceList(this.tags, {
    super.key,
    this.controller,
    this.shrinkWrap = false,
    this.onTap,
  });

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
                          ? Badge(label: Text('${tags.display.length}'))
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
