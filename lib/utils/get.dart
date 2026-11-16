import 'package:get/get.dart';
import 'package:flutter/material.dart';


S? maybeFind<S>({String? tag}) =>
    Get.isRegistered<S>(tag: tag) ? Get.find<S>(tag: tag) : null;


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


abstract mixin class const ActionBase<T>() {
  int get length;

  void invoke(T value);

  void add(void Function(T) callback);

  void remove(void Function(T) callback);

  void dispose();

  ActionBase<T> operator +(void Function(T) callback) {
    add(callback);
    return this;
  }

  ActionBase<T> operator -(void Function(T) callback) {
    remove(callback);
    return this;
  }
}


class Action<T> with ActionBase<T> {
  //
  final _subscriptions = <void Function(T)>{};

  @override
  int get length => _subscriptions.length;

  @override
  void invoke(T value) {
    for (final callback in _subscriptions) {
      callback(value);
    }
  }

  @override
  void add(void Function(T) callback) {
    _subscriptions.add(callback);
  }

  @override
  void remove(void Function(T) callback) {
    _subscriptions.remove(callback);
  }

  @override
  void dispose() {
    _subscriptions.clear();
  }
}
