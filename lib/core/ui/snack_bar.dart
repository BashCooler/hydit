import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../data/repo.dart';


void snackBar(Icon icon, String title, String message) {
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
  );
}


void showErrorOrSuccess((Result, String) result,
    {bool error = true, bool success = true}) {
  final Icon icon;
  final String title;
  final String message;

  switch (result.$1) {
    case .success:
      icon = Icon(Icons.check);
      title = 'Success';
      message = result.$2;
      if (success) {
        snackBar(icon, title, message);
      }
    case .error:
      icon = Icon(Icons.clear);
      title = 'Error';
      message = result.$2;
      if (error) {
        snackBar(icon, title, message);
      }
  }
}