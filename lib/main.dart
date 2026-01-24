import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hydrus_flutter/pages/search.dart';
import 'package:hydrus_flutter/theme.dart';


void main() {
  timeDilation = 1.0;
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,
      theme: darkTheme(),
      home: const SearchPage(),
    );
  }
}