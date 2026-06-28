import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hydit/entities/tag.dart';


class ServiceList extends StatelessWidget {
  final Map<String, Set<Tag>> combined;
  final ScrollController? controller;
  final bool shrinkWrap;
  final void Function(String name)? onTap;

  
  const ServiceList(this.combined, {
    super.key,
    this.controller,
    this.shrinkWrap = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListView(
        padding: .zero,
        controller: controller,
        shrinkWrap: shrinkWrap,
        children: [
          for (final MapEntry(key: name, value: tags) in combined.entries)
            if (name != 'all known tags')
              ListTile(
                onTap: () => onTap?.call(name),
                title: Text(name),
                trailing: Row(
                  spacing: 5,
                  mainAxisSize: .min,
                  children: [
                    ?tags.isNotEmpty
                        ? Badge(label: Text('${tags.length}'))
                        : null,
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
