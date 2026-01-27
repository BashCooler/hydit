import 'package:flutter/material.dart';


ThemeData darkTheme() {
  return ThemeData(
    brightness: .dark,
    colorSchemeSeed: Colors.blue,
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      enabledBorder: outlineInputBorder(),
      border: outlineInputBorder(),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.transparent,
      behavior: .floating,
      contentTextStyle: TextStyle(color: AppColors.fontLight),
      dismissDirection: DismissDirection.down,
      shape: outlineInputBorder(),
    ),
  );
}


OutlineInputBorder outlineInputBorder({Color borderColor = AppColors.filled}) {
  return OutlineInputBorder(
      borderRadius: BorderRadius.circular(Consts.radius),
      borderSide: BorderSide(color: borderColor),
    );
}


abstract class AppColors {
  static const filled = Color(0xFF32353a);
  static const fontDark = Color(0xFF000000);
  static const fontLight = Colors.white70;
}


abstract class Consts {
  static const radius = 10.0;
  static const blur = 8.0;
  static const blackAlpha = Color.fromARGB(128, 0, 0, 0);
  static const minZoomScale = 1.0;
  static const maxZoomScale = 4.0;
}