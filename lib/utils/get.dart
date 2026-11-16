import 'package:get/get.dart';
import 'package:flutter/material.dart';


S? maybeFind<S>({String? tag}) =>
    Get.isRegistered<S>(tag: tag) ? Get.find<S>(tag: tag) : null;


extension ToRx<T> on T {
  Rx<T> get rx => Rx<T>(this);
}


Future<T?>? to<T>(dynamic page, {
  bool opaque = false,
  Transition? transition,
  Curve curve = Curves.easeInOutCubic,
  Bindings? binding,
  dynamic arguments,
  void Function()? onOpen,
  void Function()? onClose,
}) async {
  onOpen?.call();
  try {
    return await Get.to<T>(
      page,
      opaque: opaque,
      transition: transition,
      curve: curve,
      arguments: arguments,
      binding: binding,
    );
  } finally {
    onClose?.call();
  }
}


class Action<T> {
  final _subscriptions = <void Function(T)>{};

  int get length => _subscriptions.length;

  Action<T> operator +(void Function(T) listener) {
    add(listener);
    return this;
  }

  Action<T> operator -(void Function(T) listener) {
    remove(listener);
    return this;
  }

  void invoke(T value) {
    for (final callback in _subscriptions) {
      callback(value);
    }
  }

  void add(void Function(T) listener) {
    _subscriptions.add(listener);
  }

  void remove(void Function(T) listener) {
    _subscriptions.remove(listener);
  }

  void clear() => _subscriptions.clear();
}
