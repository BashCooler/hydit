import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrus_flutter/pages/search.dart';
import 'package:hydrus_flutter/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'api/hydrus.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  getIt.registerSingleton(GetPreferences(prefs));
  getIt.registerSingleton(GetClient());

  timeDilation = 1.0;
  runApp(App(prefs));
}

class App extends StatelessWidget {
  final SharedPreferences prefs;

  const App(this.prefs, {super.key});

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

// MARK: BLOC

enum SearchVisibility {visible, hidden}
class SearchVisibilityCubit extends Cubit<SearchVisibility> {
  SearchVisibilityCubit() : super(SearchVisibility.visible);

  void show() => emit(SearchVisibility.visible);
  void hide() => emit(SearchVisibility.hidden);
}

// MARK: SERVICES

final getIt = GetIt.instance;  // global

class GetClient {
  final Client client = Client();
  GetClient();
}

class GetPreferences {
  final SharedPreferences prefs;
  GetPreferences(this.prefs);
}