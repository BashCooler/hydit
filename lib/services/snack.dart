import 'package:get/get.dart';
import 'package:flutter/material.dart';


class Snack {
  Snack._();

  static void success(String title, String message) =>
      snackBar(const Icon(Icons.check), title, message);

  static void error(String title, String message) =>
      snackBar(const Icon(Icons.clear), title, message);

  static void snackBar(Icon icon, String title, String message) {
    Get.snackbar(
      title,
      message,
      dismissDirection: .horizontal,
      snackPosition: .BOTTOM,
      duration: const Duration(seconds: 10),
      animationDuration: const Duration(milliseconds: 450),
      forwardAnimationCurve: Curves.easeOutCubic,
      backgroundColor: Get
          .theme
          .colorScheme
          .surfaceContainerHigh,
      icon: icon,
      margin: const .all(10),
    );
  }
}
