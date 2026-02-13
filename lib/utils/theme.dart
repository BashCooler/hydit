import 'dart:ui';
import 'package:flutter/material.dart';


ThemeData darkTheme() {
  return ThemeData(
    brightness: .dark,
    colorSchemeSeed: Colors.black,
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      enabledBorder: outlineInputBorder(),
      border: outlineInputBorder(),
    ),
  );
}


abstract class AppColors {
  static const filled = Color(0xFF32353a);
  static const fontDark = Color(0xFF000000);
  static const fontLight = Colors.white70;
}


abstract class AppTheme {
  static const radius = 10.0;
  static const blackAlpha = Color.fromARGB(96, 0, 0, 0);
  static const listTileHeight = 50.0;
  static const searchPadding = 15.0;
  static final backdropFilter = ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0);
  static final borderRadius = BorderRadius.circular(radius);
}


const namespaceColors = {
  'character': Color.fromARGB(255, 0, 170, 0),
  'creator': Color.fromARGB(255, 170, 0, 0),
  'meta': Color.fromARGB(255, 255, 136, 0),
  'series': Color.fromARGB(255, 170, 0, 170),
  'studio': Color.fromARGB(255, 128, 0, 0),
  'system': Color.fromARGB(255, 153, 101, 21),
  'namespace': Color.fromARGB(255, 114, 160, 193),
  'no namespace': Color.fromARGB(255, 0, 111, 250),
};


OutlineInputBorder outlineInputBorder({Color borderColor = AppColors.filled}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppTheme.radius),
    borderSide: BorderSide(color: borderColor),
  );
}