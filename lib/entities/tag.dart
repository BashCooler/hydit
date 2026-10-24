import 'package:flutter/services.dart';
import 'package:equatable/equatable.dart';

import 'package:hydit/utils/utils.dart';


class Tag(final String raw) extends Equatable {

  final int idx = raw.indexOf(':');

  late final String value = idx == -1 ? raw : raw.substring(idx + 1);

  late final String? namespace = idx == -1 ? null : raw.substring(0, idx);

  late final String pretty = raw.replaceFirst(_pattern, '').trim();

  Color get color => colorOf(namespace);

  static const Set<String> namespaces = {
    'system',
    'creator',
    'character',
    'meta',
    'series',
    'studio',
  };

  static final _pattern = RegExp('^(${namespaces.join('|')}):');

  @override
  String toString() => raw;

  @override
  List<Object?> get props => [raw];

  static void toClipboard(Tag t) =>
      Clipboard.setData(ClipboardData(text: t.raw));
}


extension IterableTagExtension on Iterable<Tag> {
  List<String> rawList() => map((t) => t.raw).toList();
}
