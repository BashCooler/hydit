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
