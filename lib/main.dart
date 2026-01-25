import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return BlocProvider(
      create: (_) => SearchVisibilityCubit(),
      child: MaterialApp(
        title: 'Flutter App',
        debugShowCheckedModeBanner: false,
        theme: darkTheme(),
        home: SearchPage(),
      ),
    );
  }
}

enum SearchVisibility {visible, hidden}
class SearchVisibilityCubit extends Cubit<SearchVisibility> {
  SearchVisibilityCubit() : super(SearchVisibility.visible);

  void show() => emit(SearchVisibility.visible);
  void hide() => emit(SearchVisibility.hidden);
}