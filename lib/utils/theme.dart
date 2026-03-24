import 'dart:ui';
import 'package:flutter/material.dart';


ThemeData darkTheme() => ThemeData(
  brightness: .dark,
  colorSchemeSeed: Colors.black,

  tooltipTheme: const TooltipThemeData(
    preferBelow: false,
    showDuration: Duration(milliseconds: 0),
  ),

  scrollbarTheme: ScrollbarThemeData(
    thumbVisibility: .all(true),
    thickness: .all(6),
    radius: .circular(3),
  ),
);

abstract class AppColors {
  static const filled = Color(0xFF32353a);
  static const fontDark = Color(0xFF000000);
  static const fontLight = Colors.white70;
  static const blackWithAlpha = Color.fromARGB(96, 0, 0, 0);
}


abstract class AppTheme {
  static const radius = 10.0;
  static const buttonSize = 48.0;
  static const fieldHeight = 55.0;
  static const outerPadding = 15.0;
  static final backdropFilter = ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0);
  static final borderRadius = BorderRadius.circular(radius);
  static final duration = Duration(milliseconds: 300);
}


const namespaceColors = {
  'character': Color.fromARGB(255, 0, 170, 0),
  'creator': Color.fromARGB(255, 170, 0, 0),
  'meta': Color.fromARGB(255, 255, 136, 0),
  'series': Color.fromARGB(255, 170, 0, 170),
  'studio': Color.fromARGB(255, 128, 0, 0),
  'system': Color.fromARGB(255, 153, 101, 21),
  'namespace': Color.fromARGB(255, 114, 160, 193),
  '_': Color.fromARGB(255, 114, 160, 193),
  'no namespace': Color.fromARGB(255, 0, 111, 250),
};


OutlineInputBorder outlineInputBorder({Color borderColor = AppColors.filled}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppTheme.radius),
    borderSide: BorderSide(color: borderColor),
  );
}