import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hydit/entities/tag.dart';

export 'theme.dart';


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
