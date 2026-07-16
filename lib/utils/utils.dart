import 'dart:convert' hide json;

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hydit/entities/tag.dart';

export 'theme.dart';
export 'url.dart';


extension ToDuration on num {
  Duration get ms => Duration(milliseconds: round());
  Duration get s =>  Duration(seconds: round());
}

Future<void> sleep(Duration duration) => Future.delayed(duration);

void copyTag(Tag tag) {
  Clipboard.setData(ClipboardData(text: tag.raw));
}


extension Unique on String {
  String unique() {
    return '$this-${DateTime.now().microsecondsSinceEpoch}';
  }
}


S? maybeFind<S>({String? tag}) {
  return Get.isRegistered<S>(tag: tag)
      ? Get.find<S>(tag: tag)
      : null;
}


extension on GetInterface {
  bool isNotRegistered<S>({String? tag}) =>
      !isRegistered<S>(tag: tag);
}


class If<T> extends StatelessWidget {
  final String? tag;
  final Widget child;
  final Widget fallback;

  const If({
    super.key,
    this.tag,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    if (Get.isNotRegistered<T>(tag: tag)) {
      return fallback;
    }
    return child;
  }
}


extension ChunckedList<T> on List<T> {

  Iterable<List<T>> chunked(int size) sync* {
    for (var i = 0; i < length; i += size) {
      yield sublist(
        i,
        (i + size).clamp(0, length),
      );
    }
  }
}


extension Decode on String {
  dynamic decode() => jsonDecode(this);
}
