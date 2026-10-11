import 'package:flutter/material.dart';

import 'package:hydit/utils/theme.dart';
import 'package:hydit/entities/tag.dart';


class const TagTile({
  super.key,
  final bool enabled = true,
  required final Tag tag,
  final Tag? _ideal,
  final Color? background,
  final Widget? trailing,
  final void Function(Tag tag)? onTap,
  final void Function(Tag tag)? onLongPress,
  final EdgeInsetsGeometry? contentPadding,
}) extends StatelessWidget {
  //
  Tag? get ideal => _ideal != null && _ideal != tag ? _ideal : null;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: .hardEdge,
      child: ListTile(
        enabled: enabled,
        onTap: () => onTap?.call(tag),
        onLongPress: () => onLongPress?.call(tag),
        tileColor: background,
        minTileHeight: Sizes.minTileHeight,
        contentPadding: contentPadding,
        title: Text.rich(
          TextSpan(
            children: [
              tag.toSpan(),
              ?ideal?.toSpan(prefix: ' ➔ '),
            ],
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}


extension TagTextSpan on Tag {
  TextSpan toSpan({String? prefix}) => TextSpan(
    text: prefix == null ? pretty : '$prefix$pretty',
    style: TextStyle(color: color),
  );
}
