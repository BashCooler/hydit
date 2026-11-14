import 'package:flutter/material.dart';

export 'theme.dart';
export 'get.dart';

export 'package:dart_scope_functions/dart_scope_functions.dart';
export 'package:dartx/dartx.dart' show IterableChunked;


extension ToDuration on num {
  Duration get ms => Duration(milliseconds: round());
  Duration get s =>  Duration(seconds: round());
}


Future<void> sleep(Duration duration) => Future.delayed(duration);


extension Unique on String {
  String unique() {
    return '$this-${DateTime.now().microsecondsSinceEpoch}';
  }
}


class Wrapper extends StatelessWidget {
  final bool condition;
  final Widget Function(Widget child) builder;
  final Widget child;

  const Wrapper({
    super.key,
    required this.condition,
    required this.builder,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => condition
      ? builder(child)
      : child;
}


extension Or<T> on T? {
  T or(T value) => this ?? value;
}


extension ScopedBool on bool {
  bool not() => !this;
}


extension Range<T> on List<T> {

  Iterable<T> range(T from, T to) {

    final a = indexOf(from);
    final b = indexOf(to);

    if (a < 0 || b < 0) return .empty();

    return getRange(
      a < b ? a : b,
      a < b ? b + 1 : a + 1,
    );
  }
}
