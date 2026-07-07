import 'package:flutter/services.dart';
import 'package:hydit/entities/tag.dart';

export 'theme.dart';


extension ToDuration on num {
  Duration get ms => Duration(milliseconds: round());
  Duration get s => (this * 1000).s;
}

Future<void> sleep(Duration duration) => Future.delayed(duration);

void copyTag(Tag tag) {
  Clipboard.setData(ClipboardData(text: tag.raw));
}
