import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/entities/tag.dart';

import 'tag_modal_sheet.dart';


class const TagTilePopup ({
  super.key,
  required final Tag tag,
  final Tag? ideal,
  final List<Tag> ancestors = const [],
}) extends StatelessWidget {
  //
  @override
  Widget build(BuildContext context) {
    final ideal = this.ideal;

    return PopupMenuButton(
      icon: Badge(
        isLabelVisible: ancestors.isNotEmpty,
        child: const Icon(Icons.more_vert),
      ),
      itemBuilder: (context) => [
        if (ancestors.isNotEmpty)
          PopupMenuItem(
            child: ''
                '${ancestors.length} ancestor'
                '${ancestors.length > 1 ? 's' : ''}'.n,
            onTap: () => showModalTagSheet(context, ancestors),
          ),

        PopupMenuItem(
          child: const Text('copy tag'),
          onTap: () => Tag.toClipboard(tag),
        ),

        if (ideal != null && ideal != tag)
          PopupMenuItem(
            child: const Text('copy ideal tag'),
            onTap: () => Tag.toClipboard(ideal),
          ),
      ],
    );
  }
}
