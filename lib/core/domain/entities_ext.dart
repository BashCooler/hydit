import 'package:flutter/material.dart';
import 'package:hydrus_flutter/utils/theme.dart';
import 'entities.dart';


extension TagUI on Tag {
  Color? get color =>
      namespaceColors[namespace] ?? namespaceColors['namespace'];

  Widget get label => Text(value, style: TextStyle(color: color));
}