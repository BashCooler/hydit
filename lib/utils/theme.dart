import 'package:flutter/material.dart';
import 'package:hydit/utils/utils.dart';


ThemeData darkTheme() => ThemeData(
  brightness: .dark,
  colorSchemeSeed: Colors.black,

  appBarTheme: const AppBarThemeData(
    elevation: 0,
    scrolledUnderElevation: 0,
  ),

  bottomAppBarTheme: const BottomAppBarThemeData(
    height: 42,
    padding: .zero,
    elevation: 8,
  ),

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


Duration get transition => 300.ms;


const addition = Color(0x333fb950);
const deletion = Color(0x33f85149);


Color colorOf(String? namespace) => switch (namespace) {
  'character' => Color.fromARGB(255, 0, 170, 0),
  'creator' => Color.fromARGB(255, 170, 0, 0),
  'meta' => Color.fromARGB(255, 255, 136, 0),
  'series' => Color.fromARGB(255, 170, 0, 170),
  'studio' => Color.fromARGB(255, 128, 0, 0),
  'system' => Color.fromARGB(255, 153, 101, 21),
  'namespace' => Color.fromARGB(255, 114, 160, 193),
  null => Color.fromARGB(255, 0, 111, 250),
  _ => Color.fromARGB(255, 114, 160, 193),
};
