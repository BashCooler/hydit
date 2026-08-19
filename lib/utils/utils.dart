import 'dart:convert' hide json;

import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:deep_pick/deep_pick.dart';
import 'package:deep_pick/deep_pick.dart' as p show pick;

export 'theme.dart';
export 'url.dart';
export 'collection.dart';
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


extension Decode on String {
  dynamic decode() => jsonDecode(this);
}


extension PickExtension on String {

  Pick pick([
    Object? arg0,
    Object? arg1,
    Object? arg2,
    Object? arg3,
    Object? arg4,
    Object? arg5,
    Object? arg6,
    Object? arg7,
    Object? arg8,
    Object? arg9,
  ]) {
    return p.pick(
      jsonDecode(this),
      arg0,
      arg1,
      arg2,
      arg3,
      arg4,
      arg5,
      arg6,
      arg7,
      arg8,
      arg9,
    );
  }
}


extension ScopeFunctions<T> on T {

  R let<R>(R Function(T it) toElement) {
    return toElement.call(this);
  }

  T also(void Function(T it) action) {
    action.call(this);
    return this;
  }
}


extension Math on num {
  num mult(num a) => this * a;

  num div(num a) => this / a;
}


extension Or<T> on T? {
  T or(T value) => this ?? value;
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


extension ToRx<T> on T {
  Rx<T> get rx => Rx<T>(this);
}
