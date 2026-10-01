import 'package:flutter/services.dart';
import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

import 'package:hydit/utils/utils.dart';


class Tag extends Equatable {
  final String raw;
  final int count;

  late final int idx = raw.indexOf(':');

  late final String value = idx
      .let((it) => it == -1 ? raw : raw.substring(it + 1));

  late final String? namespace = idx
      .let((it) => it == -1 ? null : raw.substring(0, it));

  late final String pretty = raw.replaceFirst(_pattern, '').trim();

  Tag(this.raw, {this.count = 0});

  Color get color => colorOf(namespace);

  /// The [map] parameter should be extracted from `search_tags`
  /// response like so:
  ///
  /// `json -> tags -> 0` (or other index)
  factory Tag.fromMap(Map<String, dynamic> map) =>
      Tag(map['value'], count: map['count']);

  /// The [pick] parameter should be extracted from `search_tags`
  /// response like so:
  ///
  /// `pick(json, 'tags', 0)` (or other index)
  factory Tag.fromPick(Pick pick) {
    final map = pick.asMapOrThrow<String, dynamic>();

    return Tag.fromMap(map);
  }

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
