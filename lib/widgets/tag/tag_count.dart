import 'package:flutter/material.dart';
import 'package:niku/namespace.dart' as n;

import 'package:hydit/entities/tag.dart';


class const TagCount ({
  super.key,
  required final Tag tag,
  required final int count,
}) extends StatelessWidget {
  //
  @override
  Widget build(BuildContext context) => '$count'.n
    ..color = tag.color
    ..fontSize = 14;
}
